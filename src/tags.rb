#
# You're it.
#



module Bm
  class Tags < Bm::Line


    def initialize( tags = nil )
      @pool = [ ]

      if tags.is_a? String
        self.from_s(tags)
      elsif tags.is_a? Array
        self.sort!
      end
    end

    attr_accessor :pool



    def from_s( str = '' )
      self.pool = self.sort(str.split(Bm::Utils.unit_sep))
    end


    def to_s
      self.sort!
      self.pool.join(Bm::Utils.unit_sep)
    end


    def sort( arr = self.pool )
      ret = (arr.empty?) ? [ ] : arr.sort.collect { |t| t.strip }
      return ret
    end

    def sort!
      self.pool = self.sort
    end




    # When the action is to view tags, main calls this.
    def print_tags
      tags = self.cull_tags
      tags.each { |tag,count| puts "#{tag} (#{count})" }
    end



    def cull_tags
      ret = { }

      if ((self.has_file) and (!self.nil_file))
        fh = File.open(self.file_path, 'r')
        while line = fh.gets(Bm::Utils.rec_sep)
          p = Bm::Line.to_parts(line)
          if !p[:tags].empty?
            p[:tags].each do |tag|
              ret[tag] = 0 if !ret.has_key?(tag)
              ret[tag] += 1
            end
          end
        end

        keys, tmp = ret.keys.sort, { }
        keys.each { |k| tmp[k] = ret[k] }
        ret, tmp = tmp, nil
      end

      return ret
    end


  end
end
