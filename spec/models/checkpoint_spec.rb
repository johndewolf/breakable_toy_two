require 'spec_helper'

describe Checkpoint do
  let(:checkpoint){ FactoryGirl.create(:goal).checkpoints.last }

  it { should belong_to(:goal) }

  it { should have_valid(:target).when(200) }
  it { should_not have_valid(:target).when(nil) }

  it { should have_valid(:goal).when(FactoryGirl.create(:goal)) }
  it { should_not have_valid(:goal).when(nil) }

  it { should have_valid(:complete_by).when(Date.today + 7) }
  it { should_not have_valid(:complete_by).when(nil, '') }

  it { should have_valid(:user_input).when(200) }

  describe '.next_for' do
    it 'returns a new checkpoint for a given goal' do
      goal = FactoryGirl.create(:goal)
      checkpoint = Checkpoint.next_for(goal)
      expect(checkpoint.goal).to eq goal
    end

    it "has the correct value for target" do
      goal = FactoryGirl.create(:goal,
        end_date: Date.today + 2.weeks, starting_point: 0, target: 100)
      checkpoint = Checkpoint.next_for(goal)
      expect(checkpoint.target).to eq(50)
    end

    it 'has the correct date to complete by' do
      goal = FactoryGirl.create(:goal, end_date: Date.today + 2.weeks)
      checkpoint = Checkpoint.next_for(goal)
      expect((checkpoint.complete_by).to_date).to eql(Date.today + 7)
    end

    context "it is a decreasing goal" do
      it "has the correct value for target" do
        goal = FactoryGirl.create(:goal,
        end_date: Date.today + 2.weeks, starting_point: 100, target: 0)
      checkpoint = Checkpoint.next_for(goal)
      expect(checkpoint.target).to eq(50)
      end
    end

    context "checkpoint completes the goal" do
      it "updates the goal 'completed_at'" do
        goal = FactoryGirl.create(:goal)
        FactoryGirl.create(:checkpoint, goal: goal, user_input: goal.target)
        Checkpoint.next_for(goal)
        expect(goal.completed_on).to eql(Date.today)
      end
    end
  end


  describe ".completed" do
    let!(:completed_checkpoint) { FactoryGirl.create(:completed_checkpoint) }
    let!(:not_completed_checkpoint) { FactoryGirl.create(:checkpoint) }

    it "returns checkpoints that have been completed" do
      expect(Checkpoint.completed).to include completed_checkpoint
    end

    it "doesnt return checkpoints that have not been completed" do
      expect(Checkpoint.completed).to_not include not_completed_checkpoint
    end
  end

  describe '.unit_increase' do
    it "increases the next checkpoint" do
      goal = FactoryGirl.create(:goal, end_date: Date.today + 2.weeks,
        starting_point: 0, target: 20)
      checkpoint = Checkpoint.unit_increase(goal)
      expect(checkpoint).to eql(10.0)
    end
  end

  describe '.unit_decrease' do
    it 'decreases the next checkpoint' do
    goal = FactoryGirl.create(:goal,  end_date: Date.today + 2.weeks,
      starting_point: 20, target: 0)
      checkpoint = Checkpoint.unit_decrease(goal)
      expect(checkpoint).to eql(10.0)
    end
  end


  describe '.checkpoints_remaining' do
    it 'returns the correct number of remaining checkpoints' do
      goal = FactoryGirl.create(:goal, end_date: Date.today + 2.weeks)
      Checkpoint.next_for(goal)
      expect(Checkpoint.remaining(goal)).to eql 2
    end
  end
end
