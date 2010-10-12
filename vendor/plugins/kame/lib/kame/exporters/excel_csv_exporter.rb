module Kame
  
  class ExcelCsvExporter < Kame::CsvExporter

    def send_data_code(table)
      record = "r"
      code  = Kame::SimpleFinder.new.select_data_code(table)
      code += "ic = Iconv.new('cp1252', 'utf-8')\n"
      code += "data = FasterCSV.generate(:col_sep=>';') do |csv|\n"
      code += "  csv << [#{columns_to_array(table, :header, :iconv=>'ic').join(', ')}]\n"
      code += "  for #{record} in #{table.records_variable_name}\n"  
      code += "    csv << [#{columns_to_array(table, :body, :record=>record, :iconv=>'ic').join(', ')}]\n"
      code += "  end\n"
      code += "end\n"
      code += "send_data(data, :type=>#{self.mime_type}, :disposition=>'inline', :filename=>#{table.model.name}.model_name.human.gsub(/[^a-z0-9]/i,'_')+'.#{self.file_extension}')\n"
      return code
    end

  end

end

Kame.register_exporter(:xcsv, Kame::ExcelCsvExporter)
