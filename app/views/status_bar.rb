class StatusBar < BarView
  def self.switch_methods(method_a, method_b)
    class_eval do
      alias_method "#{method_b}_original", method_b
      alias_method method_b, method_a
      alias_method method_a, "#{method_b}_original"
    end
  end
  
  %w{ topLineColor bottomLineColor }.each do |color|
    switch_methods color, "selected#{color[0,1].upcase}#{color[1..-1]}"
  end
end