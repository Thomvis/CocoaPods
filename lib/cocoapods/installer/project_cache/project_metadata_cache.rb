module Pod
  class Installer
    module ProjectCache
      # Represents the metadata cache
      #
      class ProjectMetadataCache
        require 'cocoapods/installer/project_cache/target_metadata.rb'

        # @return [Hash{String => TargetMetadata}]
        #         Hash of string by target metadata.
        #
        attr_reader :target_label_by_metadata

        # Initialize a new instance.
        #
        # @param [Hash{String => TargetMetadata}] target_label_by_metadata @see #target_label_by_metadata
        #
        def initialize(target_label_by_metadata = {})
          @target_label_by_metadata = target_label_by_metadata
        end

        def to_hash
          Hash[target_label_by_metadata.map do |target_label, metdata|
            [target_label, metdata.to_hash]
          end]
        end

        # Rewrites the entire cache to the given path.
        #
        # @param [String] path
        #
        # @return [void]
        #
        def save_as(path)
          Sandbox.update_changed_file(path, YAMLHelper.convert_hash(to_hash, nil))
        end

        # Updates the metadata cache based on installation results.
        #
        # @param [Hash{String => TargetInstallationResult}] pod_target_installation_results
        #        The installation results for pod targets installed.
        #
        # @param [Hash{String => TargetInstallationResult}] aggregate_target_installation_results
        #        The installation results for aggregate targets installed.
        #
        def update_metadata!(pod_target_installation_results, aggregate_target_installation_results)
          installation_results = pod_target_installation_results.values + aggregate_target_installation_results.values
          installation_results.each do |installation_result|
            native_target = installation_result.native_target
            target_label_by_metadata[native_target.name] = TargetMetadata.from_native_target(native_target)
          end
        end

        def self.from_file(path)
          return ProjectMetadataCache.new unless File.exist?(path)
          contents = YAMLHelper.load_file(path)
          target_by_label_metadata = Hash[contents.map { |target_label, hash| [target_label, TargetMetadata.from_hash(hash)] }]
          ProjectMetadataCache.new(target_by_label_metadata)
        end
      end
    end
  end
end
