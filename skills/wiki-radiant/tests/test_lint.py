"""Exercise the installed lint CLI and its persisted health-report contract."""

import json
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

import yaml

ROOT = Path(__file__).resolve().parents[1]
LINT_SCRIPTS = ROOT / "skills/wiki-lint/scripts"


class LintTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="radiant-lint-")
        self.addCleanup(self.temp.cleanup)
        self.vault = Path(self.temp.name)
        (self.vault / "wiki/sources").mkdir(parents=True)
        (self.vault / "wiki/concepts").mkdir()
        (self.vault / ".raw").mkdir()
        (self.vault / "wiki/index.md").write_text("# Vault\n\n## Sources\n")

    def page(self, name, raw=".raw/example.md", kind="source", indexed=True):
        path = self.vault / "wiki" / ("sources" if kind == "source" else "concepts") / name
        data = dict(title=path.stem, type=kind, description="Fixture", created="2026-09-11",
                    updated="2026-09-11", tags=["fixture"], confidence="high", schema_version="0.3")
        if kind == "source":
            data.update(resource="urn:radiant:test", raw=raw)
        else:
            data["aliases"] = ["hidden-term"]
        body = "# Example\n\nText.\n"
        if kind != "source":
            body += "\n# Citations\n"
        path.write_text("---\n" + yaml.safe_dump(data, sort_keys=False) + "---\n\n" + body)
        if indexed:
            with (self.vault / "wiki/index.md").open("a") as index:
                index.write(f"- [{name}](/{path.relative_to(self.vault).as_posix()})\n")
        return path

    def run_lint(self, scripts=LINT_SCRIPTS):
        result = subprocess.run(["bash", str(scripts / "lint.sh"), str(self.vault)],
                                capture_output=True, text=True, timeout=30)
        self.assertIn(result.returncode, (0, 1), result.stderr + result.stdout)
        health = json.loads((self.vault / "meta/vault-report.json").read_text())["health"]
        return result, health

    def test_clean_vault(self):
        (self.vault / ".raw/example.md").write_text("Original")
        self.page("example.md")
        result, health = self.run_lint()
        self.assertEqual(result.returncode, 0)
        self.assertTrue(all(not findings for findings in health.values()), health)

    def test_missing_raw(self):
        self.page("example.md")
        result, health = self.run_lint()
        self.assertEqual(result.returncode, 1)
        self.assertEqual(health["missing_raw"], ["wiki/sources/example.md"])

    def test_linked_but_unindexed_page(self):
        concept = self.page("hidden.md", kind="concept", indexed=False)
        source = self.page("example.md")
        (self.vault / ".raw/example.md").write_text("Original")
        with source.open("a") as file:
            file.write(f"\n[Hidden](/{concept.relative_to(self.vault).as_posix()})\n")
        _, health = self.run_lint()
        self.assertEqual(health["unindexed_pages"], ["wiki/concepts/hidden.md"])
        self.assertNotIn("wiki/concepts/hidden.md", health["orphan_pages"])

    def test_duplicate_sources_are_grouped(self):
        (self.vault / ".raw/example.md").write_text("Original")
        self.page("a.md")
        self.page("b.md", raw=".raw/./example.md")
        result, health = self.run_lint()
        self.assertEqual(result.returncode, 0)
        self.assertEqual(health["duplicate_sources"], [{"raw": ".raw/example.md",
                         "pages": ["wiki/sources/a.md", "wiki/sources/b.md"]}])

    def test_quoted_binary_raw_with_spaces(self):
        (self.vault / ".raw/report #1.pdf").write_bytes(b"%PDF-fixture")
        self.page("example.md", raw=".raw/report #1.pdf")
        _, health = self.run_lint()
        self.assertEqual(health["missing_raw"], [])

    def test_raw_outside_preservation_directory(self):
        (self.vault / "outside.md").write_text("Outside")
        self.page("example.md", raw=".raw/../outside.md")
        result, health = self.run_lint()
        self.assertEqual(result.returncode, 1)
        self.assertEqual(health["missing_raw"], ["wiki/sources/example.md"])

    def test_non_string_raw(self):
        self.page("example.md", raw=[".raw/a.md"])
        _, health = self.run_lint()
        self.assertEqual(health["missing_raw"], ["wiki/sources/example.md"])

    def test_missing_index_is_high(self):
        (self.vault / "wiki/index.md").unlink()
        result, _ = self.run_lint()
        self.assertEqual(result.returncode, 1)
        self.assertIn("Missing wiki/index.md", result.stdout)

    def test_invalid_source_yaml_is_high(self):
        page = self.page("example.md")
        page.write_text("---\ntitle: [unclosed\nraw: .raw/example.md\n---\nText\n")
        result, _ = self.run_lint()
        self.assertEqual(result.returncode, 1)
        self.assertIn("Invalid YAML frontmatter", result.stdout)

    def test_distinct_raw_directories_are_not_duplicates(self):
        for directory in ("first", "second"):
            (self.vault / ".raw" / directory).mkdir()
            (self.vault / ".raw" / directory / "example.md").write_text("Original")
            self.page(f"{directory}.md", raw=f".raw/{directory}/example.md")
        _, health = self.run_lint()
        self.assertEqual(health["duplicate_sources"], [])

    def test_dead_links_remain_reported(self):
        with (self.vault / "wiki/index.md").open("a") as index:
            index.write("- [Missing](/wiki/concepts/missing.md)\n")
        result, health = self.run_lint()
        self.assertEqual(result.returncode, 1)
        self.assertEqual(health["dead_links"][0]["broken_target"], "/wiki/concepts/missing.md")

    def test_standalone_hook_bundle(self):
        scripts = self.vault / "hook-bin"
        shutil.copytree(LINT_SCRIPTS, scripts)
        result, _ = self.run_lint(scripts)
        self.assertEqual(result.returncode, 0)

    def test_incomplete_install_preserves_old_report(self):
        scripts = self.vault / "incomplete"
        scripts.mkdir()
        shutil.copy2(LINT_SCRIPTS / "lint.sh", scripts)
        report = self.vault / "meta/vault-report.json"
        report.parent.mkdir()
        report.write_text('{"preserved": true}\n')
        result = subprocess.run(["bash", str(scripts / "lint.sh"), str(self.vault)],
                                capture_output=True, text=True, timeout=30)
        self.assertEqual(result.returncode, 2)
        self.assertEqual(json.loads(report.read_text()), {"preserved": True})


if __name__ == "__main__":
    unittest.main()
