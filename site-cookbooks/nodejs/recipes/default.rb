remote_file "/tmp/#{node['nodejs']['filename']}" do
  source "#{node['nodejs']['remote_url']}"
end

bash "install nodejs" do
  user "root"
  cwd "/tmp"
  code <<-EOC
    tar xvzf #{node['nodejs']['filename']}
    cd #{node['nodejs']['dirname']}
    make
    make install
  EOC
end
