#
# Methods related to tags.
#



module BM
  class Tags < BM::BM


    def self.to_a( str = '' )
      arr = str.split(BM::Utils.unit_sep)
      ret = (arr.empty?) ? [ ] : arr.sort.collect { |t| t.strip }
      return ret
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
        while line = fh.gets(BM::Utils.rec_sep)
          p = BM::Line.to_parts(line)
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
