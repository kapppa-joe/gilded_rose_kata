class GildedRose
  ITEM_GROUP_MATCHERS = {
    /^Sulfuras.*/ => :legendary,
    /^Backstage passes.*/ => :backstage_pass,
    /^Aged Brie$/ => :aged,
    /^Conjured.*/ => :conjured
  }

  MAX_QUALITY = 50
  MIN_QUALITY = 0

  def initialize(items)
    @items = items
  end

  def update_quality
    @items.each do |item|
      case self.class.detect_item_group(item)
      when :legendary
        next  # do nothing
      when :normal
        degrade_normal_item(item)
      when :conjured
        degrade_conjured_item(item)
      when :aged
        boost_item_quality(item)
      when :backstage_pass
        adjust_backstage_pass_quality(item)
      end

      decrease_sell_in_day(item)
    end
  end

  def self.detect_item_group(item)
    ITEM_GROUP_MATCHERS.each do |pattern, group_name|
      return group_name if item.name.match?(pattern)
    end

    :normal
  end

  def degrade_normal_item(item)
    change = item.sell_in.positive? ? -1 : -2
    item.quality = calc_new_item_quality(item.quality, change)
  end

  def degrade_conjured_item(item)
    change = item.sell_in.positive? ? -2 : -4
    item.quality = calc_new_item_quality(item.quality, change)
  end

  def boost_item_quality(item)
    change = item.sell_in.positive? ? 1 : 2
    item.quality = calc_new_item_quality(item.quality, change)
  end

  def adjust_backstage_pass_quality(item)
    return item.quality = 0 if item.sell_in <= 0

    greater_than = proc { |a| proc { |b| b > a } }

    case item.sell_in
    when 1..5
      change = 3
    when 6..10
      change = 2
    when greater_than[10]
      change = 1
    end

    item.quality = calc_new_item_quality(item.quality, change)
  end

  def decrease_sell_in_day(item)
    item.sell_in -= 1
  end

  def boost_item_quality(item)
    change = item.sell_in.positive? ? 1 : 2
    item.quality = calc_new_item_quality(item.quality, change)
  end

  def adjust_backstage_pass_quality(item)
    return item.quality = 0 if item.sell_in <= 0

    greater_than = proc { |a| proc { |b| b > a } }

    case item.sell_in
    when 1..5
      change = 3
    when 6..10
      change = 2
    when greater_than[10]
      change = 1
    end

    item.quality = calc_new_item_quality(item.quality, change)
  end

  def decrease_sell_in_day(item)
    item.sell_in -= 1
  end

  def calc_new_item_quality(original_quality, change)
    new_quality = original_quality + change
    new_quality = [new_quality, MAX_QUALITY].min
    new_quality = [new_quality, MIN_QUALITY].max
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
