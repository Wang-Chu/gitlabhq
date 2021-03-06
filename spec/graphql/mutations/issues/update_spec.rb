# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::Issues::Update do
  let_it_be(:project) { create(:project) }
  let_it_be(:user) { create(:user) }
  let_it_be(:project_label) { create(:label, project: project) }
  let_it_be(:issue) { create(:issue, project: project, labels: [project_label]) }

  let(:expected_attributes) do
    {
      title: 'new title',
      description: 'new description',
      confidential: true,
      due_date: Date.tomorrow,
      discussion_locked: true
    }
  end
  let(:mutation) { described_class.new(object: nil, context: { current_user: user }, field: nil) }
  let(:mutated_issue) { subject[:issue] }

  specify { expect(described_class).to require_graphql_authorizations(:update_issue) }

  describe '#resolve' do
    let(:mutation_params) do
      {
        project_path: project.full_path,
        iid: issue.iid
      }.merge(expected_attributes)
    end

    subject { mutation.resolve(mutation_params) }

    context 'when the user cannot access the issue' do
      it 'raises an error' do
        expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
      end
    end

    context 'when the user can update the issue' do
      before do
        project.add_developer(user)
      end

      it 'updates issue with correct values' do
        subject

        expect(issue.reload).to have_attributes(expected_attributes)
      end

      context 'when iid does not exist' do
        it 'raises resource not available error' do
          mutation_params[:iid] = non_existing_record_iid

          expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
        end
      end

      context 'when changing labels' do
        let_it_be(:label_1) { create(:label, project: project) }
        let_it_be(:label_2) { create(:label, project: project) }
        let_it_be(:external_label) { create(:label, project: create(:project)) }

        it 'adds and removes labels correctly' do
          mutation_params[:add_label_ids] = [label_1.id, label_2.id]
          mutation_params[:remove_label_ids] = [project_label.id]

          subject

          expect(issue.reload.labels).to match_array([label_1, label_2])
        end

        it 'does not add label if label id is nil' do
          mutation_params[:add_label_ids] = [nil, label_2.id]

          subject

          expect(issue.reload.labels).to match_array([project_label, label_2])
        end

        it 'does not add label if label is not found' do
          mutation_params[:add_label_ids] = [external_label.id, label_2.id]

          subject

          expect(issue.reload.labels).to match_array([project_label, label_2])
        end

        it 'does not modify labels if label is already present' do
          mutation_params[:add_label_ids] = [project_label.id]

          expect(issue.reload.labels).to match_array([project_label])
        end

        it 'does not modify labels if label is addded and removed in the same request' do
          mutation_params[:add_label_ids] = [label_1.id, label_2.id]
          mutation_params[:remove_label_ids] = [label_1.id]

          subject

          expect(issue.reload.labels).to match_array([project_label, label_2])
        end
      end
    end
  end
end
