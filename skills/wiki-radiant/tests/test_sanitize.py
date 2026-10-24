"""Verify that the ingestion boundary retains its credential redaction."""

import json
from pathlib import Path
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "skills/wiki-ingest/scripts/sanitize.sh"


class SanitizeTests(unittest.TestCase):
    def test_redacts_synthetic_token_in_saved_output(self):
        with tempfile.TemporaryDirectory(prefix="radiant-sanitize-") as directory:
            source = Path(directory) / "input.md"
            synthetic = "sk-" + "testfixture" * 3
            source.write_text(f"Example token: {synthetic}\nUseful context remains.\n")
            result = subprocess.run(["bash", str(SCRIPT), str(source)],
                                    capture_output=True, text=True, check=True)
            report = json.loads(result.stdout)
            self.assertTrue(report["redacted"])
            self.assertNotIn(synthetic, source.read_text())
            self.assertIn("<REDACTED>", source.read_text())
            self.assertIn("Useful context remains.", source.read_text())


if __name__ == "__main__":
    unittest.main()
