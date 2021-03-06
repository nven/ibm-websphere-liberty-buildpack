# Encoding: utf-8
# IBM WebSphere Application Server Liberty Buildpack
# Copyright 2013-2015 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'liberty_buildpack/repository'
require 'liberty_buildpack/repository/repository_index'
require 'liberty_buildpack/util/tokenized_version'

module LibertyBuildpack
  module Repository

    # A class encapsulating details of a file stored in a versioned repository.
    class ConfiguredItem

      private_class_method :new

      class << self

        # Finds an instance of the file based on the configuration and wraps any exceptions
        # to identify the component.
        #
        # @param [String] component_name the name of the component
        # @param [Hash] configuration the configuration
        # @option configuration [String] :repository_root the root directory of the repository
        # @option configuration [String] :version the version of the file to resolve
        # @yield [Block] optional version_validator to yield to
        # @return [String] the URI of the chosen version of the file
        # @return [LibertyBuildpack::Util::TokenizedVersion] the chosen version of the file
        def find_item(component_name = nil, configuration)
          repository_root = repository_root(configuration)
          version         = version(configuration)

          yield version if block_given?

          index = index(repository_root)
          index.find_item version
        rescue => e
          raise RuntimeError, "#{component_name} error: #{e.message}", e.backtrace unless component_name.nil?
        end

        private

        KEY_REPOSITORY_ROOT = 'repository_root'.freeze

        KEY_VERSION = 'version'.freeze

        private_constant :KEY_REPOSITORY_ROOT, :KEY_VERSION

        def index(repository_root)
          RepositoryIndex.new(repository_root)
        end

        def repository_root(configuration)
          unless configuration.key? KEY_REPOSITORY_ROOT
            fail "A repository root must be specified as a key-value pair of '#{KEY_REPOSITORY_ROOT}'' to the URI of the repository."
          end

          configuration[KEY_REPOSITORY_ROOT]
        end

        def version(configuration)
          LibertyBuildpack::Util::TokenizedVersion.new(configuration[KEY_VERSION])
        end

      end

    end

  end
end
