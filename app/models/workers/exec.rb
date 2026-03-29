class CMDTask < Task

  def perform(params)

      cmd = params['cmd']

      # out = `#{cmd}`

      eval cmd


      puts "FINISH"


  end

end
