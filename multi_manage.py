import argparse
from os import scandir
from pathlib import Path
from subprocess import check_output, PIPE, run, CalledProcessError
from sys import stderr, exit


class Executor:
    def __init__(self, debug=False, simulate=None):
        self.debug = debug
        self.simulate = simulate

    def __error(self, cmd, msg, exit_on_errors=False):
        print(f"Error running: {cmd}", file=stderr)
        print(f"  --> {msg} \n", file=stderr)
        if exit_on_errors:
            exit(1)

    def run(self, run_cmd=[], fail_on_errors=True, show_errors=True, return_all_info=False, cwd=None):
        if self.debug:
            print(f"EXEC {' '.join(run_cmd)}")
        if self.simulate:
            return
        try:
            r = run(run_cmd, stdout=PIPE, stderr=PIPE, cwd=cwd)
        except CalledProcessError as e:
            if return_all_info:
                return r
            return False
        # if return_all_info is enabled return result object
        if return_all_info:
            return r

        if r.returncode == 0:
            return True
        else:
            if show_errors:
                self.__error(run_cmd, f"{r.stderr.decode('utf-8')}", fail_on_errors)
            return False


class MultiRepoManager:
    def __init__(self, simulate):
        self.working_directories = self.get_working_subdirectories()
        self.simulate = simulate
        self.executor = Executor(simulate=simulate, debug=True)

    # command could be a list (just one command with its parameters)
    # or a list of list, several commands
    def __exec_in_directories(self, commands):
        results = []
        for directory in self.working_directories:
            print(f'DIR {directory}')
            # if just one command convert to list of lists
            if not any(isinstance(el, list) for el in commands):
                commands = [commands]
            for command in commands:
                if self.simulate:
                    print(' '.join(command))
                else:
                    results.append(self.executor.run(command, return_all_info=True, cwd=directory))
        return results

    def get_working_subdirectories(self):
        return [f.path for f in scandir('.') if f.is_dir()]

    def run(self, action, params):
        if action == 'show':
            results = self.__exec_in_directories([['pwd'], ['git', 'branch']])
            for r in results:
                print(r.stdout.decode())
        elif action == 'exec':
            results = self.__exec_in_directories(params)
            for r in results:
                print(r.stdout.decode())
        elif action == 'exec-script':
            script_file = Path(params[0]).absolute()
            if not script_file.exists():
                print(f'Script {script_file} not found', file=stderr)
                exit(1)
            results = self.__exec_in_directories(['/bin/bash', str(script_file)])
            for r in results:
                print(r.stdout.decode())
                print(r.stderr.decode())
        else:
            print(f"Action unknown: {action}", file=stderr)
            exit(1)


def main():
    usage = "%(prog) <action> [--simulate]"
    parser = argparse.ArgumentParser(usage)
    parser.add_argument('action', default='')
    parser.add_argument('params', nargs='*', default='')
    parser.add_argument('-s', '--simulate',
                        action='store_true',
                        help='Perform a dry-run')
    args = parser.parse_args()

    if not args.action:
        parser.error('Missing command')

    manager = MultiRepoManager(simulate=args.simulate)
    manager.run(args.action, args.params)


if __name__ == '__main__':
    main()
