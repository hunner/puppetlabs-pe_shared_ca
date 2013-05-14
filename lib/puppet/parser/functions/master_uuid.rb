require 'puppet/face'

Puppet::Parser::Functions.newfunction(:master_uuid, :type => :rvalue) do |args|
  master        = args[0]
  dns_alt_names = args[1]
  require'ruby-debug';debugger;1
  Puppet::Face[:resource, :current].autosign_conf
  # if no uuid cert
  #   # this is the ca checking in
  #   if no cert
  #     enforce autosign
  #     generate cert
  #   else
  #     # nothing; waiting for pm
  #   end
  # else
  #   # this is the pm checking in
  #   revoke uuid cert
  #   enforce no autosign
  #   # puppet adds cert to catalog
  #   # puppet adds rm uuid cert to catalog
  # end
end
