# frozen_string_literal: true

module Gitlab
  module Ci
    ##
    # Ci::Features is a class that aggregates all CI/CD feature flags in one place.
    #
    module Features
      def self.artifacts_exclude_enabled?
        ::Feature.enabled?(:ci_artifacts_exclude, default_enabled: true)
      end

      def self.job_heartbeats_runner?(project)
        ::Feature.enabled?(:ci_job_heartbeats_runner, project, default_enabled: true)
      end

      def self.instance_variables_ui_enabled?
        ::Feature.enabled?(:ci_instance_variables_ui, default_enabled: true)
      end

      def self.composite_status?(project)
        ::Feature.enabled?(:ci_composite_status, project, default_enabled: true)
      end

      def self.atomic_processing?(project)
        ::Feature.enabled?(:ci_atomic_processing, project, default_enabled: true)
      end

      def self.pipeline_latest?
        ::Feature.enabled?(:ci_pipeline_latest, default_enabled: true)
      end

      def self.pipeline_status_omit_commit_sha_in_cache_key?(project)
        Feature.enabled?(:ci_pipeline_status_omit_commit_sha_in_cache_key, project)
      end

      def self.release_generation_enabled?
        ::Feature.enabled?(:ci_release_generation, default_enabled: true)
      end

      # Remove in https://gitlab.com/gitlab-org/gitlab/-/issues/224199
      def self.store_pipeline_messages?(project)
        ::Feature.enabled?(:ci_store_pipeline_messages, project, default_enabled: true)
      end

      # Remove in https://gitlab.com/gitlab-org/gitlab/-/issues/227052
      def self.variables_api_filter_environment_scope?
        ::Feature.enabled?(:ci_variables_api_filter_environment_scope, default_enabled: false)
      end

      # This FF is only used for development purpose to test that warnings can be
      # raised and propagated to the UI.
      def self.raise_job_rules_without_workflow_rules_warning?
        ::Feature.enabled?(:ci_raise_job_rules_without_workflow_rules_warning)
      end

      def self.keep_latest_artifacts_for_ref_enabled?(project)
        ::Feature.enabled?(:keep_latest_artifacts_for_ref, project, default_enabled: false)
      end

      def self.destroy_only_unlocked_expired_artifacts_enabled?
        ::Feature.enabled?(:destroy_only_unlocked_expired_artifacts, default_enabled: false)
      end

      def self.parallel_matrix_enabled?
        ::Feature.enabled?(:ci_parallel_matrix_enabled)
      end

      def self.bulk_insert_on_create?(project)
        ::Feature.enabled?(:ci_bulk_insert_on_create, project, default_enabled: true)
      end

      def self.ci_if_parenthesis_enabled?
        ::Feature.enabled?(:ci_if_parenthesis_enabled)
      end

      def self.allow_to_create_merge_request_pipelines_in_target_project?(target_project)
        ::Feature.enabled?(:ci_allow_to_create_merge_request_pipelines_in_target_project, target_project, default_enabled: true)
      end

      def self.ci_plan_needs_size_limit?(project)
        ::Feature.enabled?(:ci_plan_needs_size_limit, project)
      end

      def self.job_entry_matches_all_keys?
        ::Feature.enabled?(:ci_job_entry_matches_all_keys)
      end
    end
  end
end

::Gitlab::Ci::Features.prepend_if_ee('::EE::Gitlab::Ci::Features')
