class GildedRose
  ITEM_GROUP_MATCHERS = {
    /^Sulfuras.*/ => :legendary,
    /^Backstage passes.*/ => :backstage_pass,
    /^Aged Brie$/ => :aged,
    /^Conjured.*/ => :conjured
  }

  def initialize(items)
    @items = items
  end

  def update_quality()
    @items.each do |item|
      item_group = self.class.detect_item_group(item)

      if item_group == :legendary
        # do nothing
      elsif item_group == :normal
        degrade_normal_item(item)
        decrease_sell_in_day(item)
      elsif item_group == :aged
        boost_item_quality(item)
        decrease_sell_in_day(item)
      else
        original_update_quality_for_single_item(item)
      end
    end
  end

  def original_update_quality_for_single_item(item)
    if item.name != "Aged Brie" and item.name != "Backstage passes to a TAFKAL80ETC concert"
      if item.quality > 0
        if item.name != "Sulfuras, Hand of Ragnaros"
          item.quality = item.quality - 1
        end
      end
    else
      if item.quality < 50
        item.quality = item.quality + 1
        if item.name == "Backstage passes to a TAFKAL80ETC concert"
          if item.sell_in < 11
            if item.quality < 50
              item.quality = item.quality + 1
            end
          end
          if item.sell_in < 6
            if item.quality < 50
              item.quality = item.quality + 1
            end
          end
        end
      end
    end
    if item.name != "Sulfuras, Hand of Ragnaros"
      item.sell_in = item.sell_in - 1
    end
    if item.sell_in < 0
      if item.name != "Aged Brie"
        if item.name != "Backstage passes to a TAFKAL80ETC concert"
          if item.quality > 0
            if item.name != "Sulfuras, Hand of Ragnaros"
              item.quality = item.quality - 1
            end
          end
        else
          item.quality = item.quality - item.quality
        end
      else
        if item.quality < 50
          item.quality = item.quality + 1
        end
      end
    end
  end

  def self.detect_item_group(item)
    ITEM_GROUP_MATCHERS.each do |pattern, group_name|
      return group_name if item.name.match?(pattern)
    end

    :normal
  end

  def degrade_normal_item(item)
    if item.sell_in.positive?
      item.quality = [0, item.quality - 1].max
    else
      item.quality = [0, item.quality - 2].max
    end
  end

  def boost_item_quality(item)
    if item.sell_in.positive?
      item.quality = [50, item.quality + 1].min
    else
      item.quality = [50, item.quality + 2].min
    end
  end

  def decrease_sell_in_day(item)
    item.sell_in -= 1
  end
end

class Item
  attr_accessor :name, :sell_in, :quality

  def initialize(name, sell_in, quality)
    @name = name
    @sell_in = sell_in
    @quality = quality
  end

  def to_s()
    "#{@name}, #{@sell_in}, #{@quality}"
  end
end
