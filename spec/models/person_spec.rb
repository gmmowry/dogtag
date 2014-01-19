require 'spec_helper'

describe Person do

  describe 'validation' do
    it 'passes with all required parameters' do
      expect(FactoryGirl.build(:person).valid?).to eq(true)
    end

    it 'fails with invalid years of experience' do
      expect(FactoryGirl.build(:person, :experience => -10)).to be_invalid
    end

    it 'fails on bad email address' do
      expect(FactoryGirl.build(:person, :email => 'bad@email')).to be_invalid
      expect(FactoryGirl.build(:person, :email => 'bad@email.')).to be_invalid
      expect(FactoryGirl.build(:person, :email => 'bademail.com')).to be_invalid
      expect(FactoryGirl.build(:person, :email => '@bademail.com')).to be_invalid
      expect(FactoryGirl.build(:person, :email => 'bad@email.a')).to be_invalid
    end

    it 'passes when twitter starts with an @ sign' do
      expect(FactoryGirl.build(:person, :twitter => 'bad')).to be_invalid
      expect(FactoryGirl.build(:person, :twitter => '@good')).to be_valid
    end

    it 'fails if associated with a registration with race.people_per_team people already assigned' do
      person_hash = FactoryGirl.attributes_for :person
      reg = FactoryGirl.create :registration
      reg.race.people_per_team.times { |x| reg.people.create person_hash }
      person = reg.people.new person_hash
      expect(person).to be_invalid
      expect(person.errors.messages[:maximum]).to eq(['people already added to this registration'])
    end

  end
end


