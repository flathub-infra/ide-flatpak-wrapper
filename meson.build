project('vscode-flatpak-wrapper')

bash = find_program('bash')
pymod = import('python')
python = pymod.find_installation('python3')

editor = find_program(get_option('editor_binary'), required: false)
if editor.found()
editor_path = editor.path()
else
editor_path = get_option('editor_binary')
endif
message('Using @0@ as editor binary'.format(editor_path))

if get_option('flatpak_id') == ''
flatpak_id = run_command('sh', '-c', 'echo $FLATPAK_ID').stdout().strip()
else
flatpak_id = get_option('flatpak_id')
endif
datadir = join_paths(get_option('prefix'), get_option('datadir'), meson.project_name())

if get_option('sdk_version') == ''
sdk_version = run_command('sh', '-c', '. /etc/os-release && echo ${VERSION_ID%.*}').stdout().strip()
else
sdk_version = get_option('sdk_version')
endif

wrapper_data = configuration_data({
    'BASH': bash.path(),
    'EDITOR_BINARY': editor_path,
    'FIRST_RUN_README': join_paths(datadir, 'first_run.txt'),
    'SDK_UPDATE_README': join_paths(datadir, 'sdk_update.txt'),
    'SDK_VERSION': sdk_version,
    'PROGRAM_NAME': get_option('program_name'),
    'DATA_DIR_NAME': get_option('data_dir_name'),
    'PYTHON_VERSION': python.language_version()
})

readme_data = configuration_data({
    'FLATPAK_ID': flatpak_id,
    'SDK_VERSION': sdk_version
})

configure_file(input: 'vscode.sh',
               output: get_option('program_name'),
               configuration: wrapper_data,
               install_dir: get_option('bindir'),
               install_mode: 'rwxr-xr-x')

configure_file(input: 'first_run.txt',
               output: 'first_run.txt',
               configuration: readme_data,
               install_dir: datadir)

configure_file(input: 'sdk_update.txt',
               output: 'sdk_update.txt',
               configuration: readme_data,
               install_dir: datadir)
