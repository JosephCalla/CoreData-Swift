//
//  ViewController.swift
//  ToDoList
//
//  Created by Joseph Estanislao Calla Moreyra on 28/11/22.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var table: UITableView!
    var listTask = [Tarea]()
    let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchTask()
    }

    @IBAction func buttonAction(_ sender: Any) {
        
        var nameTask = UITextField()
        let alert = UIAlertController(title: "New", message: "Task", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Add", style: .default) { _ in
            let newTask = Tarea(context: self.contexto)
            newTask.name = nameTask.text
            newTask.done = false
            self.listTask.append(newTask)
            self.save()
        }
        
        alert.addTextField { textFieldAlert  in
            textFieldAlert.placeholder = "Escribe tu texto aquí ..."
            nameTask = textFieldAlert
        }
        
        alert.addAction(alertAction)
        present(alert, animated: true)
    }
    
    private func save() {
        do {
            try contexto.save()
        } catch {
            print(error.localizedDescription)
        }
        
        self.table.reloadData()
    }
    
    func fetchTask() {
        let request : NSFetchRequest<Tarea> = Tarea.fetchRequest()
        
        do {
            listTask = try contexto.fetch(request)
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listTask.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let task = listTask[indexPath.row]
        
        // operator ternario
        cell.textLabel?.text = task.name
        cell.textLabel?.textColor = task.done ? .black : .blue
        
        cell.detailTextLabel?.text = task.done ? "Completada": "Por completar"
        
        // Marcar con una paloma las tareas completas
        cell.accessoryType = task.done ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Palomear la tarea
        if table.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            table.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            table.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        // Editar coredata
        listTask[indexPath.row].done = !listTask[indexPath.row].done
        
        save()
        
        // Deseleccionar la tarea
        table.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let actionRemove = UIContextualAction(style: .normal, title: "Eliminar") { [self] _, _, _ in
            contexto.delete(listTask[indexPath.row])
            
            listTask.remove(at: indexPath.row)
            
            save()
        }
        
        actionRemove.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [actionRemove])
    }
    
}

