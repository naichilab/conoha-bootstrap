#
# Author:: Adam Jacob (adam@opscode.com)
# Copyright:: Copyright (c) 2009 Opscode
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'spec_helper'

describe Chef::Provider::Script, "action_run" do
  let(:node) { Chef::Node.new }

  let(:events) { Chef::EventDispatch::Dispatcher.new }

  let(:run_context) { Chef::RunContext.new(node, {}, events) }

  let(:new_resource) {
    new_resource = Chef::Resource::Script.new('run some perl code')
    new_resource.code "$| = 1; print 'i like beans'"
    new_resource.interpreter 'perl'
    new_resource
  }

  let(:provider) { Chef::Provider::Script.new(new_resource, run_context) }

  let(:tempfile) { Tempfile.open("rspec-provider-script") }

  before(:each) do
    allow(provider).to receive(:shell_out!).and_return(true)
    allow(provider).to receive(:script_file).and_return(tempfile)
  end

  context "#script_file" do
    it "creates a temporary file to store the script" do
      allow(provider).to receive(:script_file).and_call_original
      expect(provider.script_file).to be_an_instance_of(Tempfile)
    end
  end

  context "#unlink_script_file" do
    it "unlinks the tempfile" do
      tempfile_path = tempfile.path
      provider.unlink_script_file
      expect(File.exist?(tempfile_path)).to be false
    end
  end

  context "#set_owner_and_group" do
    it "sets the owner and group for the script file" do
      new_resource.user 'toor'
      new_resource.group 'wheel'
      expect(FileUtils).to receive(:chown).with('toor', 'wheel', tempfile.path)
      provider.set_owner_and_group
    end
  end

  context "with the script file set to the correct owner and group" do
    before do
      allow(provider).to receive(:set_owner_and_group)
    end

    describe "when writing the script to the file" do
      it "should put the contents of the script in the temp file" do
        allow(provider).to receive(:unlink_script_file)  # stub to avoid remove
        provider.action_run
        expect(IO.read(tempfile.path)).to eq("$| = 1; print 'i like beans'\n")
        provider.unlink_script_file
      end

      it "closes before executing the script and unlinks it when finished" do
        tempfile_path = tempfile.path
        provider.action_run
        expect(tempfile).to be_closed
        expect(File.exist?(tempfile_path)).to be false
      end
    end

    describe "when running the script" do
      let (:default_opts) {
        {timeout: 3600, returns: 0, log_level: :info, log_tag: "script[run some perl code]", live_stream: STDOUT}
      }

      before do
        allow(STDOUT).to receive(:tty?).and_return(true)
      end

      it 'should set the command to "interpreter"  "tempfile"' do
        expect(provider.command).to eq(%Q{"perl"  "#{tempfile.path}"})
      end

      it 'should call shell_out! with the command' do
        expect(provider).to receive(:shell_out!).with(provider.command, default_opts).and_return(true)
        provider.action_run
      end

      it "should set the command to 'interpreter flags tempfile'" do
        new_resource.flags '-f'
        expect(provider.command).to eq(%Q{"perl" -f "#{tempfile.path}"})
      end
    end
  end

end
