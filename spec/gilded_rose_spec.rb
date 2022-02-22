# frozen_string_literal: true

require 'gilded_rose'

describe GildedRose do
  describe '#update_quality' do
    context 'with all known items' do
      before(:each) do
        @items = [
          Item.new(name = '+5 Dexterity Vest', sell_in = 10, quality = 20),
          Item.new(name = 'Aged Brie', sell_in = 2, quality = 0),
          Item.new(name = 'Elixir of the Mongoose', sell_in = 5, quality = 7),
          Item.new(name = 'Sulfuras, Hand of Ragnaros', sell_in = 0, quality = 80),
          Item.new(name = 'Sulfuras, Hand of Ragnaros', sell_in = -1, quality = 80),
          Item.new(name = 'Backstage passes to a TAFKAL80ETC concert', sell_in = 15, quality = 20),
          Item.new(name = 'Backstage passes to a TAFKAL80ETC concert', sell_in = 10, quality = 49),
          Item.new(name = 'Backstage passes to a TAFKAL80ETC concert', sell_in = 5, quality = 49),
          Item.new(name = 'Conjured Mana Cake', sell_in = 3, quality = 6) # <-- :O
        ]
        @gilded_rose = described_class.new(@items)
      end

      it 'does not change the name and the order of items' do
        original_names = @items.map(&:name)
        @gilded_rose.update_quality
        @items.each_with_index do |item, index|
          expect(item.name).to eq original_names[index]
        end
      end

      it 'does not change the total number of items' do
        number_of_items = @items.size
        @gilded_rose.update_quality
        expect(@items.size).to be number_of_items
      end

      it 'never lower the quality of an item to negative' do
        100.times do
          GildedRose.new(@items).update_quality
        end
        expect(@items.map(&:quality)).to all(be >= 0)
      end
    end

    context 'with only normal items' do
      before(:each) do
        @normal_items = [
          Item.new(name = '+5 Dexterity Vest', sell_in = 10, quality = 20),
          Item.new(name = 'Elixir of the Mongoose', sell_in = 5, quality = 7)
        ]
        @gilded_rose = described_class.new(@normal_items)
      end

      it 'lowers the sell_in for every normal item at the end of each day' do
        sell_in_on_0th_day = @normal_items.map(&:sell_in)
        @gilded_rose.update_quality
        expect(@normal_items[0].sell_in).to eq sell_in_on_0th_day[0] - 1
        expect(@normal_items[1].sell_in).to eq sell_in_on_0th_day[1] - 1

        @gilded_rose.update_quality
        expect(@normal_items[0].sell_in).to eq sell_in_on_0th_day[0] - 2
        expect(@normal_items[1].sell_in).to eq sell_in_on_0th_day[1] - 2
      end

      it 'lowers the quality for every normal item at the end of each day' do
        quality_on_0th_day = @normal_items.map(&:quality)
        @gilded_rose.update_quality
        expect(@normal_items[0].quality).to eq quality_on_0th_day[0] - 1
        expect(@normal_items[1].quality).to eq quality_on_0th_day[1] - 1

        @gilded_rose.update_quality
        expect(@normal_items[0].quality).to eq quality_on_0th_day[0] - 2
        expect(@normal_items[1].quality).to eq quality_on_0th_day[1] - 2
      end

      it 'lowers the quality twice as fast once the sell by date has passed' do
        quality_on_0th_day = @normal_items.map(&:quality)
        @normal_items[0].sell_in = 1

        @gilded_rose.update_quality
        expect(@normal_items[0].quality).to eq quality_on_0th_day[0] - 1

        @gilded_rose.update_quality
        expect(@normal_items[0].quality).to eq quality_on_0th_day[0] - 1 - 2

        @gilded_rose.update_quality
        expect(@normal_items[0].quality).to eq quality_on_0th_day[0] - 1 - 2 - 2
      end
    end

    context 'with legendary items' do
      before(:each) do
        @legendary_items = [
          Item.new(name = 'Sulfuras, Hand of Ragnaros', sell_in = 0, quality = 80),
          Item.new(name = 'Sulfuras, Hand of Ragnaros', sell_in = -1, quality = 80)
        ]
        @gilded_rose = GildedRose.new(@legendary_items)
      end

      it 'do not change the sell_in and quality' do
        sell_in_on_0th_day = @legendary_items.map(&:sell_in)
        quality_on_0th_day = @legendary_items.map(&:quality)
        10.times do
          @gilded_rose.update_quality
          @legendary_items.each_with_index do |item, index|
            expect(item.sell_in).to eq sell_in_on_0th_day[index]
            expect(item.quality).to eq quality_on_0th_day[index]
          end
        end
      end
    end

    context 'with non-legendary items' do
      before(:each) do
        @non_legendary_items = [
          Item.new(name = '+5 Dexterity Vest', sell_in = 10, quality = 20),
          Item.new(name = 'Aged Brie', sell_in = 2, quality = 0),
          Item.new(name = 'Elixir of the Mongoose', sell_in = 5, quality = 7),
          Item.new(name = 'Backstage passes to a TAFKAL80ETC concert', sell_in = 15, quality = 20),
          Item.new(name = 'Backstage passes to a TAFKAL80ETC concert', sell_in = 10, quality = 49),
          Item.new(name = 'Backstage passes to a TAFKAL80ETC concert', sell_in = 5, quality = 49),
          Item.new(name = 'Conjured Mana Cake', sell_in = 3, quality = 6) # <-- :O
        ]
        @gilded_rose = GildedRose.new(@non_legendary_items)
      end

      it 'ensure the quality of an item to never be more than 50' do
        50.times do
          @gilded_rose.update_quality
          expect(@non_legendary_items.map(&:quality)).to all(be <= 50)
        end
      end
    end

    context 'with "Aged Brie"' do
      it 'increases in Quality the older it gets'
    end

    context 'with "Backstage passes"' do
      it 'increases in quality as its sell_in value approaches'
      it 'quality increases by 2 when there are 10 days or less'
      it 'quality increases by 3 when there are 5 days or less'
      it 'quality drops to 0 after the concert'
    end
  end
end
