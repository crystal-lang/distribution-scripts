name "tgz_package"
default_version "0.0.1"
skip_transitive_dependency_licensing true

build do
  block do
    platform = ohai['os']
    target_arch = ohai['target_arch'] || ohai['kernel']['machine']
    destination = File.expand_path('pkg', Omnibus::Config.project_root)
    version = "#{project.build_version}-#{project.build_iteration}"
    version.gsub!("/", "-")
    tgz_name = "#{project.name}-#{version}-#{platform}-#{target_arch}.tar.gz"
    if macos? || mac_os_x?
      transform = "-s /./#{project.name}-#{version}/"
    else
      transform = %(--transform="s/./#{project.name}-#{version}/")
    end

    command "tar czf #{destination}/#{tgz_name} #{transform} -C #{install_dir} .",
      env: {"COPYFILE_DISABLE" => "1"}

    # NOTE: For environments not in English, git_cache function expected to see message 
    #       from git `nothing to commit`, otherwise it raises the error.
    #       It creates a empty file to commit something.
    command "date > #{install_dir}/tgz_package_done.log"
  end
end
