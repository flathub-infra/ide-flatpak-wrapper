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

if get_option('sdk_version') == ''
    sdk_version_cmd = run_command('sh', '-c', '. /etc/os-release && echo $VERSION_ID', check: true)
    sdk_version_arr = sdk_version_cmd.stdout().strip().split('.')
    sdk_version = '.'.join([sdk_version_arr[0], sdk_version_arr[1]])
else
    sdk_version = get_option('sdk_version')
endif

if get_option('electron').enabled()
    electron_enabled = true
elif get_option('electron').auto()
    electron_enabled = get_option('zypak').enabled()
else
    if get_option('zypak').enabled()
        error('`electron` feature is required if `zypak` is enabled')
    endif
    electron_enabled = false
endif

editor_args = []
foreach arg : get_option('editor_args')
    editor_args += '"@0@"'.format(arg)
endforeach

zypak_args = []
foreach arg : get_option('zypak_args')
    zypak_args += '"@0@"'.format(arg)
endforeach

export_envs = []
foreach env : get_option('envs')
    var = env.split('=')
    export_envs += 'export @0@="@1@"'.format(var[0], var[1])
endforeach

export_envs_inner = []
foreach env : get_option('envs_inner')
    var = env.split('=')
    export_envs_inner += 'export @0@="@1@"'.format(var[0], var[1])
endforeach

wrapper_name = '@0@-wrapper'.format(get_option('program_name'))
wrapper_dir = join_paths(get_option('prefix'), get_option('bindir'))
wrapper_path = join_paths(wrapper_dir, wrapper_name)

first_run_template = files(get_option('first_run_template'))
sdk_update_template = files(get_option('sdk_update_template'))
first_run_filename = fs.name(get_option('first_run_template'))
sdk_update_filename = fs.name(get_option('sdk_update_template'))

wrapper_data = configuration_data({
    'BASH': bash.path(),
    'WRAPPER_PATH': wrapper_path,
    'EDITOR_BINARY': editor_path,
    'EDITOR_ARGS': ' '.join(editor_args),
    'ELECTRON_ENABLED': electron_enabled.to_int(),
    'ZYPAK_ARGS': ' '.join(zypak_args),
    'EXPORT_ENVS': ' && '.join(export_envs),
    'EXPORT_ENVS_INNER': ' && '.join(export_envs_inner),
    'EDITOR_TITLE': get_option('editor_title'),
    'FIRST_RUN_README': join_paths(datadir, first_run_filename),
    'SDK_UPDATE_README': join_paths(datadir, sdk_update_filename),
    'FLAGFILE_PREFIX': get_option('flagfile_prefix'),
    'SDK_VERSION': sdk_version,
    'PROGRAM_NAME': get_option('program_name'),
    'PYTHON_VERSION': python.language_version(),
    'DEFAULT_LOGLEVEL': get_option('default_loglevel'),
})

readme_data = configuration_data({
    'FLATPAK_ID': flatpak_id,
    'EDITOR_TITLE': get_option('editor_title'),
    'SDK_VERSION': sdk_version
})

if get_option('zypak').enabled()
    zypak_helper = find_program('zypak-helper')
    zypak_bindir = fs.parent(zypak_helper.path())
    zypak_libdir = join_paths(fs.parent(fs.parent(zypak_helper.path())), 'lib')
    wrapper_data.set('ZYPAK_BINDIR', zypak_bindir)
    wrapper_data.set('ZYPAK_LIBDIR', zypak_libdir)
else
    wrapper_data.set('ZYPAK_BINDIR', '')
    wrapper_data.set('ZYPAK_LIBDIR', '')
endif

configure_file(input: 'editor-wrapper.sh',
               output: wrapper_name,
               configuration: wrapper_data,
               install_dir: wrapper_dir,
               install_mode: 'rwxr-xr-x')

configure_file(input: 'editor.sh',
               output: get_option('program_name'),
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
