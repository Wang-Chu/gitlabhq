# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Import::GithubController do
  include ImportSpecHelper

  let(:provider) { :github }

  include_context 'a GitHub-ish import controller'

  describe "GET new" do
    it_behaves_like 'a GitHub-ish import controller: GET new'

    it "redirects to GitHub for an access token if logged in with GitHub" do
      allow(controller).to receive(:logged_in_with_provider?).and_return(true)
      expect(controller).to receive(:go_to_provider_for_permissions).and_call_original
      allow(controller).to receive(:authorize_url).with(users_import_github_callback_url).and_call_original

      get :new

      expect(response).to have_gitlab_http_status(:found)
    end

    it "prompts for an access token if GitHub not configured" do
      allow(controller).to receive(:github_import_configured?).and_return(false)
      expect(controller).not_to receive(:go_to_provider_for_permissions)

      get :new

      expect(response).to have_gitlab_http_status(:ok)
    end

    context 'when importing a CI/CD project' do
      it 'always prompts for an access token' do
        allow(controller).to receive(:github_import_configured?).and_return(true)

        get :new, params: { ci_cd_only: true }

        expect(response).to render_template(:new)
      end
    end
  end

  describe "GET callback" do
    before do
      allow(controller).to receive(:get_token).and_return(token)
      allow(controller).to receive(:oauth_options).and_return({})

      stub_omniauth_provider('github')
    end

    it "updates access token" do
      token = "asdasd12345"

      get :callback

      expect(session[:github_access_token]).to eq(token)
      expect(controller).to redirect_to(status_import_github_url)
    end
  end

  describe "POST personal_access_token" do
    it_behaves_like 'a GitHub-ish import controller: POST personal_access_token'
  end

  describe "GET status" do
    it_behaves_like 'a GitHub-ish import controller: GET status'

    context 'when using OAuth' do
      before do
        allow(controller).to receive(:logged_in_with_provider?).and_return(true)
      end

      context 'when OAuth config is missing' do
        let(:new_import_url) { public_send("new_import_#{provider}_url") }

        before do
          allow(controller).to receive(:oauth_config).and_return(nil)
        end

        it 'returns missing config error' do
          expect(controller).to receive(:go_to_provider_for_permissions).and_call_original

          get :status

          expect(session[:"#{provider}_access_token"]).to be_nil
          expect(controller).to redirect_to(new_import_url)
          expect(flash[:alert]).to eq('OAuth configuration for GitHub missing.')
        end
      end
    end

    context 'when feature remove_legacy_github_client is disabled' do
      before do
        stub_feature_flags(remove_legacy_github_client: false)
      end

      it 'uses Gitlab::LegacyGitHubImport::Client' do
        expect(controller.send(:client)).to be_instance_of(Gitlab::LegacyGithubImport::Client)

        get :status
      end
    end

    context 'when feature remove_legacy_github_client is enabled' do
      before do
        stub_feature_flags(remove_legacy_github_client: true)
      end

      it 'uses Gitlab::GithubImport::Client' do
        expect(controller.send(:client)).to be_instance_of(Gitlab::GithubImport::Client)

        get :status
      end
    end
  end

  describe "POST create" do
    it_behaves_like 'a GitHub-ish import controller: POST create'

    it_behaves_like 'project import rate limiter'
  end

  describe "GET realtime_changes" do
    it_behaves_like 'a GitHub-ish import controller: GET realtime_changes'
  end
end
