require 'cosmic'
require 'cosmic/plugin'

require_with_hint 'net/ssh', "In order to use the ssh plugin please run 'gem install net-ssh'"
require_with_hint 'net/scp', "In order to use the ssh plugin please run 'gem install net-scp'"

module Cosmic
  # A plugin that makes SSH and SCP available to Cosmic scripts, e.g. to perform actions on remote
  # servers or to transfer files. You'd typically use it in a Cosmic context like so:
  #
  #     with ssh do
  #       exec :host => host, :cmd => "uname -a"
  #
  #       first = true
  #       upload :host => service.host, :local => local, :remote => remote do |ch, name, sent, total|
  #         print "\r" unless first
  #         print "#{name}: #{sent}/#{total}"
  #         first = false
  #       end
  #       print "\n"
  #     end
  #
  # By default, the plugin assumes that the locally running ssh agent process is configured to
  # interact with the remote servers without needing passwords (i.e. by having keys registered).
  # In this case, it will not need a configuration section unless you want more than one instance
  # of the plugin (which is not really necessary in this case as the plugin does not maintain state).
  #
  # Alternatively, you can configure it to use specific ssh keys, which you can either reference
  # directly in the configuration, or have the plugin fetch them from a specific LDAP path.
  #
  # Lastly, the plugin can determine username & password using the normal environment
  # authentication mechanisms, e.g. from the configuration or from LDAP.
  #
  # Note that this plugin will not actually connect to the remote servers in dry-run mode.
  # Instead it will only send messages tagged as `:ssh` and `:dryrun`.
  class SSH < Plugin
    # The plugin's configuration
    attr_reader :config

    # Creates a new ssh plugin instance.
    #
    # @param [Environment] environment The Cosmic environment
    # @param [Symbol] name The name for this plugin instance e.g. in the config
    # @return [SSH] The new instance
    def initialize(environment, name = :ssh)
      @name = name.to_s
      @environment = environment
      @config = @environment.get_plugin_config(:name => name.to_sym)
      @environment.resolve_service_auth(:service_name => name.to_sym, :config => @config)
      @ssh_opts = {}
      if @config[:auth][:keys] || @config[:auth][:key_data]
        @ssh_opts[:keys] = @config[:auth][:keys]
        @ssh_opts[:key_data] = @config[:auth][:key_data]
        @ssh_opts[:keys_only] = true
      elsif @config[:auth][:password]
        @ssh_opts[:password] = @config[:auth][:password]
      end
    end

    # Executes a command on a remote host and returns the output (stdin & stderr combined) of the
    # command.
    #
    # @param [Hash] params The parameters
    # @option params [String] :host The host to connect to 
    # @option params [String] :user The user to use for the ssh connection; if not specified
    #                               then it will use the username from the credentials if configured,
    #                               or the current user
    # @option params [String] :cmd The command to run on the host
    # @return [String] All output of the command (stdout and stderr combined)
    def exec(params)
      host = params[:host] or raise "No :host argument given"
      user = params[:user] || @config[:auth][:username]
      cmd = params[:cmd] or raise "No :cmd argument given"
      if @environment.in_dry_run_mode
        notify(:msg => "[#{@name}] Would execute command '#{cmd}' as user #{user} on host #{host}",
               :tags => [:ssh, :dryrun])
      else
        response = nil
        Net::SSH.start(host, user, @ssh_opts) do |ssh|
          response = ssh.exec!(cmd)
        end
        notify(:msg => "[#{@name}] Executed command '#{cmd}' as user #{user} on host #{host}",
               :tags => [:ssh, :trace])
        response
      end
    end

    # Transfers a local file to a remote host.
    #
    # @param [Hash] params The parameters
    # @option params [String] :host The host to copy the file to
    # @option params [String] :user The user to use for the ssh connection; if not specified
    #                               then it will use the username from the credentials if configured,
    #                               or the current user
    # @option params [String] :local The local path to the file to upload
    # @option params [String] :remote The remote path to the file to upload; if not specified then
    #                                 it will use the local path for this
    # @yield An optional block of arity 4 that will be executed whenever a new chunk of data is sent;
    #        the arguments are: the chunk, the filename, the number of bytes sent so far, the size
    #        of the file
    # @return [void]
    def upload(params, &block)
      host = params[:host] or raise "No :host argument given"
      user = params[:user] || @config[:auth][:username]
      local = params[:local] or raise "No :local argument given"
      remote = params[:remote] || params[:local]
      if @environment.in_dry_run_mode
        notify(:msg => "[#{@name}] Would upload local file #{local} as user #{user} to host #{host} at #{remote}",
               :tags => [:ssh, :dryrun])
      else
        response = nil
        Net::SCP.start(host, user, @ssh_opts) do |scp|
          scp.upload!(local, remote, &block)
        end
        notify(:msg => "[#{@name}] Uploaded local file #{local} as user #{user} to host #{host} at #{remote}",
               :tags => [:ssh, :trace])
      end
    end

    # Downloads a remote file from a remote host.
    #
    # @param [Hash] params The parameters
    # @option params [String] :host The host to copy the file to
    # @option params [String] :user The user to use for the ssh connection; if not specified
    #                               then it will use the username from the credentials if configured,
    #                               or the current user
    # @option params [String] :local The local target path for the downloaded file to upload; if not
    #                                specified then it will use the remote path for this
    # @option params [String] :remote The remote path to the file to download
    # @yield An optional block of arity 4 that will be executed whenever a new chunk of data is received;
    #        the arguments are: the chunk, the filename, the number of bytes received so far, the size
    #        of the file
    # @return [void]
    def download(params, &block)
      host = params[:host] or raise "No :host argument given"
      user = params[:user] || @config[:auth][:username]
      local = params[:local] || params[:remote]
      remote = params[:remote] or raise "No :remote argument given"
      if @environment.in_dry_run_mode
        notify(:msg => "[#{@name}] Would download remote file #{remote} as user #{user} from host #{host} to local file #{local}",
               :tags => [:ssh, :dryrun])
      else
        response = nil
        Net::SCP.start(host, user, @ssh_opts) do |scp|
          scp.download!(remote, local, &block)
        end
        notify(:msg => "[#{@name}] Downloaded remote file #{remote} as user #{user} from host #{host} to local file #{local}",
               :tags => [:ssh, :trace])
      end
    end
  end
end
