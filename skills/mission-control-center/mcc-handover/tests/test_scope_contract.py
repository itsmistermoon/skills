"""Contrato documental de la interfaz de resolución de mcc-handover."""
from pathlib import Path
import unittest


class ScopeContractTests(unittest.TestCase):
    def test_scope_prefers_explicit_then_backend_then_generic(self):
        skill = (Path(__file__).resolve().parents[1] / 'SKILL.md').read_text()
        step = skill.split('1. **Resolve context.**', 1)[1].split('2. **Prepare state.**', 1)[0]
        explicit = step.index('`scope:<path>,<path>`')
        backend = step.index('comando de resolución de scope que declare ese documento')
        generic = step.index('`Scope:`')
        self.assertLess(explicit, backend)
        self.assertLess(backend, generic)
        for rule in ('fleet/map --scope <rol>', 'Si el backend o su comando falla', 'usa solo el repo base', 'Add the base repo'):
            self.assertIn(rule, step)


if __name__ == '__main__':
    unittest.main()
