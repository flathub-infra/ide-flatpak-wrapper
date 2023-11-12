project('ide-flatpak-wrapper')

bash = find_program('bash')
pymod = import('python')
python = pymod.find_installation('python3')
fs = import('fs')

editor = find_program(get_option('editor_binary'), required: false)
if editor.found()
    editor_path = editor.path()
else
    editor_path = get_option('editor_binary')
    if editor_path == ''
        error('Editor binary path is empty')
    endif
endif
message('Using @0@ as editor binary'.format(editor_path))

if get_option('flatpak_id') == ''
    flatpak_id = run_command('sh', '-c', 'echo $FLATPAK_ID', check: true).stdout().strip()
else
    flatpak_id = get_option('flatpak_id')
endif
datadir = join_paths(get_option('prefix'), get_option('datadir'), meson.project_name())
libdir = join_paths(get_option('prefix'), get_option('libdir'), meson.project_name())

if get_option('sdk_version') == ''
    sdk_version_cmd = run_command('sh', '-c', '. /etc/os-release && echo $VERSION_ID', check: true)
    sdk_version_arr = sdk_version_cmd.stdout().strip().split('.')
    sdk_version = '.'.join([sdk_version_arr[0], sdk_version_arr[1]])
else
    sdk_version = get_option('sdk_version')
endif

editor_args = []
foreach arg : get_option('editor_args')
    editor_args += '"@0@"'.format(arg)
endforeach

first_run_template = files(get_option('first_run_template'))
sdk_update_template = files(get_option('sdk_update_template'))
first_run_filename = fs.name(get_option('first_run_template'))
sdk_update_filename = fs.name(get_option('sdk_update_template'))

wrapper_data = configuration_data({
    'BASH': bash.path(),
    'EDITOR_BINARY': editor_path,
    'EDITOR_ARGS': ' '.join(editor_args),
    'EDITOR_TITLE': get_option('editor_title'),
    'FIRST_RUN_README': join_paths(datadir, first_run_filename),
    'SDK_UPDATE_README': join_paths(datadir, sdk_update_filename),
    'FLAGFILE_PREFIX': get_option('flagfile_prefix'),
    'SDK_VERSION': sdk_version,
    'PROGRAM_NAME': get_option('program_name'),
    'PYTHON_VERSION': python.language_version(),
    'DEFAULT_LOGLEVEL': get_option('default_loglevel'),
    'WRAPPER_SCRIPT': join_paths(libdir, 'wrapper.sh'),
})

readme_data = configuration_data({
    'FLATPAK_ID': flatpak_id,
    'EDITOR_TITLE': get_option('editor_title'),
    'SDK_VERSION': sdk_version
})

configure_file(input: 'wrapper.sh',
               output: 'wrapper.sh',
               configuration: wrapper_data,
               install_dir: libdir)

configure_file(input: 'editor.sh',
               output: get_option('program_name'),
               configuration: wrapper_data,
               install_dir: get_option('bindir'),
               install_mode: 'rwxr-xr-x')

configure_file(input: 'shell_wrapper.sh',
               output: get_option('shell_wrapper_name'),
               configuration: wrapper_data,
               install_dir: get_option('bindir'),
               install_mode: 'rwxr-xr-x')

configure_file(input: first_run_template,
               output: first_run_filename,
               configuration: readme_data,
               install_dir: datadir)

configure_file(input: sdk_update_template,
               output: sdk_update_filename,
               configuration: readme_data,
               install_dir: datadir)
