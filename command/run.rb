puts 'Drager'


cusys = Esm.find_by_name('cusys')

project =  cusys.projects.find_by_name 'www'

@context = cusys

models = project.get_model

mpatient =  models[:patient] 



puts patients 


puts 'Finish'