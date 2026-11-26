import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import time
import unittest

SCRIPTS = Path(__file__).resolve().parents[1] / 'scripts'


class WatchTests(unittest.TestCase):
    def test_spawn_arms_watch_without_parent_process(self):
        """El recibo conserva un watch relanzable que observa la entrega atómica."""
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            task = root / 'task.md'
            task.write_text('Prueba de lectura')
            harness = root / 'spawn.lua'
            harness.write_text('''
local scripts, folder = arg[1], arg[2]
local original_dofile = dofile
local task_dir
rex = {
 args={name="watch-probe",cwd=folder,task=folder.."/task.md",command="probe",notify="file"},
 layout={block=function(options) return options end},
 exec=function(argv)
  if argv[1]=="mkdir" then task_dir=argv[3]; os.execute("mkdir -p '"..argv[3].."'"); return {ok=true} end
  if argv[1]=="sh" then return {ok=os.execute(argv[3])==0} end
  return {ok=false}
 end,
 call=function(method, args)
  if method=="block.method" then return {status="ok",path=folder} end
  if method=="session.view" then return {windows={}} end
  if method=="session.new_window" then return {window_id="window:probe",block_ids={"block:probe"}} end
  return {}
 end,
}
original_dofile(scripts.."/spawn.lua")
''')
            (root / 'rex').write_text('#!/bin/sh\necho "Do you want to proceed"\n')
            (root / 'rex').chmod(0o755)
            env = dict(os.environ, PATH=folder+':'+os.environ['PATH'], REX_SESSION='session:probe', REX_BLOCK='block:parent', TMPDIR=folder)
            # lib.root uses /tmp: choose a unique name, then remove only this probe's artifacts.
            proc = subprocess.run(['luajit', str(harness), str(SCRIPTS), folder], env=env, text=True, capture_output=True)
            self.assertEqual(proc.returncode, 0, proc.stderr)
            receipt = dict(line.split(': ', 1) for line in proc.stdout.splitlines() if ': ' in line)
            task_dir = Path(receipt['folder'])
            try:
                self.assertIn('watch log', receipt)
                restart = task_dir / 'watch-start.sh'
                self.assertTrue(restart.exists())
                log = Path(receipt['watch log'])

                def wait_for(text):
                    for _ in range(200):
                        if log.exists() and text in log.read_text():
                            return
                        time.sleep(.01)
                    self.fail(f'{text} ausente en {log.read_text()}')

                wait_for('watch exit: 2')
                result = Path(receipt['result'])
                result.write_text('STATUS: blocked\nPrueba bloqueada\n')
                subprocess.run(['bash', str(restart)], env=env, check=True)
                wait_for('watch exit: 0')
                self.assertIn('report:', log.read_text())
                result.rename(task_dir / 'result.previous.md')
                result.write_text('STATUS: completed\nFollow-up resuelto\n')
                subprocess.run(['bash', str(restart)], env=env, check=True)
                wait_for('watch exit: 0')
                self.assertIn('report:', log.read_text())
            finally:
                # El watch inicial termina al ver la entrega, sin tocar paneles reales.
                shutil.rmtree(task_dir)
                (Path('/tmp/rex-fleet/depth') / 'probe').unlink(missing_ok=True)

    def test_invalid_report_is_not_delivery(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            (root / 'rex').write_text('#!/bin/sh\nexit 1\n')
            (root / 'rex').chmod(0o755)
            report = root / 'result.md'
            report.write_text('incompleto\n')
            proc = subprocess.run(['bash', str(SCRIPTS / 'watch.sh'), 'fake', 'fake', str(report)], env=dict(os.environ, PATH=folder+':'+os.environ['PATH']), capture_output=True, text=True)
            self.assertEqual(proc.returncode, 1, proc.stdout)
            self.assertIn('pane gone', proc.stdout)


if __name__ == '__main__':
    unittest.main()
