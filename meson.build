project('vscode-flatpak-wrapper')

bash = find_program('bash')

pymod = import('python')
python = pymod.find_installation('python3')

editor = find_program(get_option('editor_binary'))

wrapper_data = configuration_data({
    'BASH': bash.path(),
    'EDITOR_BINARY': editor.path(),
    'PROGRAM_NAME': get_option('program_name'),
    'DATA_DIR_NAME': get_option('data_dir_name'),
    'PYTHON_VERSION': python.language_version()
})

configure_file(input: 'vscode.sh',
               output: get_option('program_name'),
               configuration: wrapper_data,
               install_dir: get_option('bindir'),
               install_mode: 'rwxr-xr-x')
