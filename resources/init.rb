#
# Cookbook Name:: aem
# Resource:: init
#
# Copyright 2012, Tacit Knowledge, Inc.
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

# This resource creates an init script for AEM

actions :add

attribute :service_name, :kind_of => String, :name_attribute => true, :required => true
attribute :aem_options, :kind_of => Hash, :default => nil
attribute :default_context, :kind_of => String, :default => nil
attribute :runnable_jar, :kind_of => String, :default => nil
attribute :base_dir, :kind_of => String, :default => nil
attribute :jvm_opts, :kind_of => Array, :default => nil
attribute :jar_opts, :kind_of => Array, :default => nil
