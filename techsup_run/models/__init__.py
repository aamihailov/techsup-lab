import Admins                   #                                    --.      | 1
import DepartmentActivitySphere # --.                                  |      | 3
import Department               # <-'                 --.              |      | 2
import DetailCategory           # --.                   |              |      | 4
import DetailModel              # <-'                   |  --.         |      | 5
import EmployeeRole             # --.                   |    |         |      | 9
import Employee                 # <-'       --.  --.    |    |  --.  <-' <-.  | 6
import EmployeeOperationType    # --.         |    |    |    |    |        |  | 14
import EmployeeOperation        # <-'       <-'    |  <-'    |    |        |  | 7
import EquipmentCategory        #      --.         |         |    |        |  | 11
import EquipmentModel           # --.  <-'         |         |    |        |  | 12
import Equipment                # <-'  --.         |         |    |        |  | 10
import EquipmentOperationType   # --.    |         |         |    |        |  | 14
import EquipmentOperation       # <-'  <-'         |  --.    |    |        |  | 13
import EquipmentOwner           #                  |    |    |    |        |  | 15
import TaskPriority             #           --.    |    |    |    |        |  | 20
import Task                     # --.  --.  <-'  <-'    |    |    |        |  | 17
import Repair                   # <-'    |  <-.       <-'  <-'    |        |  | 16
import TaskState                # --.    |    |                   |        |  | 21
import TaskOperation            # <-'  <-'  --'                 <-'        |  | 19
import Technics                 #                                        --'  | 22

all_models = [Admins.Admins,
              Department.Department,
              DepartmentActivitySphere.DepartmentActivitySphere,
              DetailCategory.DetailCategory,
              DetailModel.DetailModel,
              Employee.Employee,
              EmployeeOperation.EmployeeOperation,
              EmployeeOperationType.EmployeeOperationType,
              EmployeeRole.EmployeeRole,
              Equipment.Equipment,
              EquipmentCategory.EquipmentCategory,
              EquipmentModel.EquipmentModel,
              EquipmentOperation.EquipmentOperation,
              EquipmentOperationType.EquipmentOperationType,
              EquipmentOwner.EquipmentOwner,
              Repair.Repair,
              Task.Task,
              TaskOperation.TaskOperation,
              TaskPriority.TaskPriority,
              TaskState.TaskState,
              Technics.Technics]