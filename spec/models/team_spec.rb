require 'spec_helper'

describe Team do

  describe 'scopes' do
    describe 'all_finalized' do
      before do
        @finalized = FactoryGirl.create :finalized_team
        FactoryGirl.create :team
      end

      it 'returns only finalized teams' do
        expect(Team.all_finalized).to eq([@finalized])
      end
    end

    describe 'all_unfinalized' do
      before do
        FactoryGirl.create :finalized_team
        @unfinalized = FactoryGirl.create :team
      end

      it 'returns only finalized teams' do
        expect(Team.all_unfinalized).to eq([@unfinalized])
      end
    end
  end

  describe 'validation' do
    let(:race) { FactoryGirl.create :race }
    let(:team) { FactoryGirl.create :team }

    context 'succeeds' do
      it 'when all required parameters are present' do
        expect(team).to be_valid
      end

      it 'when a race is open' do
        expect(FactoryGirl.build :team, race: race).to be_valid
      end
    end

    context 'fails' do
      it 'when the same team name registers for a race more than once' do
        expect(FactoryGirl.create :team, name: 'mushfaces', race: race).to be_valid
        expect(FactoryGirl.build :team, name: 'mushfaces', race: race).to be_invalid
      end
    end

    it 'a team can be named the same in different races' do
      race2 = FactoryGirl.create :race
      expect(FactoryGirl.create :team, name: 'mushfaces', race: race).to be_valid
      expect(FactoryGirl.build :team, name: 'mushfaces', race: race2).to be_valid
    end
  end

  describe '.unfinalized' do
    it 'returns true when team is unfinalized 'do
      team = FactoryGirl.create :team
      expect(team.unfinalized).to be_true
    end

    it 'returns false when team is finalized 'do
      team = FactoryGirl.create :finalized_team
      expect(team.unfinalized).to be_false
    end
  end

  describe '.person_experience' do

    context "when there are no people on the team" do
      let(:team) { FactoryGirl.create :team }
      it "returns 0" do
        expect(team.person_experience).to eq(0)
      end
    end

    context "when there are people on the team" do
      let(:team) { FactoryGirl.create :team, :with_people }
      it "sums their total experience" do
        expect(team.person_experience).to eq(12)
      end
    end
  end

  describe '.jsonform_value' do
    context 'when team has jsonform data' do
      it 'returns the value'
    end
    context 'when team has no jsonform data' do
      it 'returns nil'
    end
    context 'when team does not have jsonform data for a certain key' do
      it 'returns nil'
    end
  end

  describe '#completed_questions?' do
    context 'race has no jsonform'
    context 'race has a jsonform' do
      context 'team has jsonform data'
      context 'team has no jsonform data'
    end
  end

  describe ".money_paid_in_cents" do
    it "reports the amount of money a team has paid according to its completed requirements"
  end

  describe '#export' do
    it 'sets the correct columns'
    it 'returns a multi-dimensional array of teams'
  end

  describe '#percent_complete' do

    context "when no people have been added and payment requirements are not satisfied" do
      let(:req) { FactoryGirl.create :payment_requirement }
      let(:team) { FactoryGirl.create :team, race: req.race}

      it "returns 0" do
        expect(team.percent_complete).to eq(0)
      end
    end

    context "when no people have been added and payment requirements are satisfied" do
      before do
        req = FactoryGirl.create :payment_requirement_with_tier
        @team = FactoryGirl.create :team, race: req.race
        FactoryGirl.create :completed_requirement, requirement: req, team: @team
      end

      it "returns correct percentage" do
        expect(@team.percent_complete).to eq(16)
      end
    end

    context "when some people have been added and payment requirements are not satisfied" do
      let(:req) { FactoryGirl.create :payment_requirement_with_tier }
      let(:team) { FactoryGirl.create :team, :with_people, race: req.race }

      it "returns correct percentage" do
        expect(team.percent_complete).to eq(66)
      end
    end

    context "when some people have been added and payment requirements are satisfied" do
      let(:team) { FactoryGirl.create :team, :with_people }
      let(:req) { FactoryGirl.create :payment_requirement_with_tier, race: team.race }
      let(:cr) { FactoryGirl.create :completed_requirement, requirement: req, team: team }

      it "returns correct percentage" do
        expect(team.percent_complete).to eq(80)
      end
    end

    context "when all people have been added and payment requirements are satisfied" do
      let(:team) { FactoryGirl.create :team, :with_people, people_count: 5 }
      let(:req) { FactoryGirl.create :payment_requirement_with_tier, race: team.race }
      let(:cr) { FactoryGirl.create :completed_requirement, requirement: req, team: team }

      it "returns 100 percent" do
        expect(team.percent_complete).to eq(100)
      end
    end

    context 'when race has some jsonschema' do
      context 'and team does not'
      context 'and team does also'
    end
  end

  describe '#needs_people?' do
    let(:race) { FactoryGirl.create :race }
    let(:reg) { FactoryGirl.create :team, :with_people, :race => race, :people_count => (race.people_per_team - 1) }

    it 'returns true if there are less than race.people_per_team people' do
      expect(reg.needs_people?).to be_true
    end

    it 'returns false if there are race.people_per_team people' do
      reg.people << FactoryGirl.create(:person)
      expect(reg.needs_people?).to be_false
    end
  end

  describe '#waitlist_position' do
    it 'returns our position on the waitlist by created_at date'
  end

  describe '#is_full?' do
    it 'should be the opposite of #needs_people?' do
      reg = FactoryGirl.create :team
      reg.stub(:needs_people?).and_return false
      expect(reg.is_full?).to eq(true)
    end
  end

  describe '#meets_finalization_requirements?' do
    before do
      @reg = FactoryGirl.create :team
    end

    it "returns true if it doesn't need people, and all requirements are met" do
      @reg.stub(:completed_all_requirements?).and_return true
      @reg.stub(:is_full?).and_return true
      expect(@reg.meets_finalization_requirements?).to be_true
    end

    it "returns false if it needs people, and all requirements are met" do
      @reg.stub(:completed_all_requirements?).and_return true
      @reg.stub(:is_full?).and_return false
      expect(@reg.meets_finalization_requirements?).to be_false
    end

    it "returns false if it doesn't need people, and all requirements are NOT met" do
      @reg.stub(:completed_all_requirements?).and_return false
      @reg.stub(:is_full?).and_return true
      expect(@reg.meets_finalization_requirements?).to be_false
    end

    it "returns false if it needs people, and all requirements are NOT met" do
      @reg.stub(:completed_all_requirements?).and_return false
      @reg.stub(:is_full?).and_return false
      expect(@reg.meets_finalization_requirements?).to be_false
    end
  end

  describe '#completed_all_requirements?' do
    before do
      @reg = FactoryGirl.create :team
      @race = @reg.race
      req = FactoryGirl.create :enabled_payment_requirement, :race => @race
      FactoryGirl.create :completed_requirement, :requirement => req, :team => @reg
    end

    it 'returns true when a race has no requirements' do
      reg = FactoryGirl.create :team
      expect(reg.completed_all_requirements?).to eq(true)
    end

    it 'returns true when all enabled requirements are completed' do
      expect(@reg.completed_all_requirements?).to eq(true)
    end

    it 'return false if any enabled requirements are not completed' do
      FactoryGirl.create :enabled_payment_requirement, :race => @race
      expect(@reg.completed_all_requirements?).to eq(false)
    end

    it "ignores a race's requirement when requirement.enabled? == false" do
      FactoryGirl.create :payment_requirement, :race => @race
      expect(@reg.completed_all_requirements?).to eq(true)
    end
  end
end
