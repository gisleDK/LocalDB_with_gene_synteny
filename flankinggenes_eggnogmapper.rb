#!/usr/bin/env ruby
# Written using Ruby 2.7.2p137
# Uses <samples>.emapper.annotations output from eggnog-mapper and
# a genes of interest list. Flanking genes are written to stdout and
# the number of cooccurences for each gene is written to output file.
# Needs to be rewritten and optimized in Python.

require 'pp'
require 'optparse'

ARGV << "-h" if ARGV.empty?

cmd_init = File.basename($0) + " " + ARGV.join(" ")

options = {}

OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename(__FILE__)} [options]"

  opts.on("-h", "--help", "Display this screen" ) do
    $stderr.puts opts
    exit
  end

  opts.on("-l", "--goi_file <file>", String, "List containing genes of interest") do |o|
    options[:goi_file] = o
  end
 
  opts.on("-g", "--eggnogmapper_output <file>", String, "Eggnog-mapper <sample>.emapper.annotations file to process") do |o|
    options[:domtblout_file] = o
  end

  opts.on("-f", "--flanking_genes <int>", Integer, "Number of flanking genes to output (default 5)") do |o|
    options[:flank] = o
  end
 
  opts.on("-o", "--output cooccurence <file>", String, "cooccurence fraction of domains output file") do |o|
    options[:cooccur_file] = o
  end

end.parse!

options[:flank]   ||= 5

class Correlations
 
  attr_writer   :dataset
  attr_accessor :total_appearance_count
  attr_accessor :seen_together_count
 
  def initialize(dataset)
    self.dataset = dataset
    self.total_appearance_count = Hash.new(0)
    self.seen_together_count = Hash.new(0)
  end
 
  def count_appearance(list)
    list.each do |item|
      @total_appearance_count[item] += 1
    end
  end
 
  def count_appearance_of_pair(pair)
    pair.sort!
    @seen_together_count[pair] += 1
  end
 
  def count_dataset
    @dataset.each do |list|
      count_appearance(list)
      pairs = list.combination(2).to_a
      pairs.each do |pair|
        count_appearance_of_pair(pair)
      end
    end
  end
 
  def correlate(options)
    puts "Missing cooccurrence output filename" if options[:cooccur_file] == nil
    exit if options[:cooccur_file] == nil
    count_dataset
    correlations = []
    @total_appearance_count.each do |item, count|
      @seen_together_count.each do |pair, pair_count|
        if pair.include?(item)
          correlation = pair_count
          comparison_item = (pair - [item])[0]
          correlations << Correlation.new(item, comparison_item, correlation)
        end
      end
    end
    File.open(options[:cooccur_file], "w+") do |i|
      correlations.sort.each do |correl|
      	i.puts "#{correl.from.join("\t")}\t#{correl.to.join("\t")}\t#{correl.correlation}"
      end
    end
  end
end
 
class Correlation
 
  attr_accessor :from
  attr_accessor :to
  attr_accessor :correlation

  def initialize(from, to, correlation)
    self.from, self.to, self.correlation = from, to, correlation
  end
 
  def <=>(other)
    s = "#{self.from}#{self.correlation - 100}"
    o = "#{other.from}#{other.correlation - 100}"
    s <=> o
  end
 
  def correlation_fraction
    sprintf('%.1f', correlation )
  end
 
  def to_s
  "#{from}\t#{to}\t#{correlation_fraction}"
  end
end

data_struct = Hash.new { |hash, key| hash[key] = {} }
  File.open(options[:domtblout_file]) do |ios|
    ios.each_line do |line|
      line.chomp!
      if line[0] == '#'
      else
        fields = line.split(/\t/)
        id     = fields[0].split('_')[0..6].join("_")
        cid    = fields[0].split('_').values_at(0..1).join("_")
        number = fields[0].split("_").last.to_i
        domain = fields.values_at(1,7)
        data_struct[cid][number] = [id, domain]
      end
    end
  end

goi_list = []

  File.open(options[:goi_file]) do |ios|
    ios.each_line do |line|
      line.chomp!
      if line[0] == '#'
        else
        goi_list << line
      end
    end
  end

flank_list = []
cooccurrence = []

goi_list.each do |goi|
  fields = goi.split("_")
  cid    = fields[0..1].join("_")
  index  = fields.last.to_i
  if data_struct.has_key? cid
  	occurence = []
    (index - options[:flank]).upto(index - 1).each  do |i| 
    	flank_list << data_struct[cid][i]
    end
    (index + 1).upto(index + options[:flank]).each  do |i| 
    	flank_list << data_struct[cid][i]
    end 
    flank_list.each do |tuple|
      if tuple
      occurence << tuple.last
      occurence.uniq!
      end
    end
    cooccurrence << occurence
  end
end

correlations = Correlations.new(cooccurrence)
correlations.correlate(options)

flank_list.each do |tuple|
  if tuple
    puts tuple.join("\t")
  end
end
