# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe MessageBroker::SortedArray do
  let(:new_item) { 8 }
  let(:sorted_sequence) { [0,1,2,3,4,5,6,7,9] }
  let(:unsorted_sequence) { [3,2,7,4,1,5,6,9,0] }

  subject { MessageBroker::SortedArray.new(unsorted_sequence) }

  it 'stays sorted' do
    subject.inspect.eql? sorted_sequence.inspect
  end

  describe '#<<' do
    it 'put new item on its ordered position' do
      subject << new_item
      expect(subject.send(:index, new_item)).to equal(new_item)
    end
  end

  describe '#delete_first' do
    let(:first_item) { sorted_sequence.first }

    it 'removes first item from the array' do
      expect(subject.delete_first).to equal(first_item)
    end
  end
end
