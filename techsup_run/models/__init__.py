import DepartmentActivitySphere # --.
import Department               # <-'            --.
import DetailCategory           # --.              |
import DetailModel              # <-'              |  --.
import EmployeeRole             # --.              |    |
import RightsGroup              #   |  --.         |    |
import Employee                 # <-'  <-'  --.    |    |
import EmployeeOperationType    # --.         |    |    |
import EmployeeOperation        # <-'       <-'  <-'    |  --.
import EquipmentModel           # --.                   |    |
import Equipment                # <-'  --.              |    |
import EquipmentOperationType   # --.    |              |    |
import EquipmentOperation       # <-'  <-'       --.    |    |
import TaskPriority             #           --.    |    |    |
import Task                     # --.  --.  <-'    |    |    |
import Repair                   # <-'    |       <-'  <-'    |
import TaskState                # --.    |                   |
import TaskOperation            # <-'  <-'                 <-'

all_models = [Department.Department,
              DepartmentActivitySphere.DepartmentActivitySphere,
              DetailCategory.DetailCategory,
              DetailModel.DetailModel,
              Employee.Employee,
              EmployeeOperation.EmployeeOperation,
              EmployeeOperationType.EmployeeOperationType,
              EmployeeRole.EmployeeRole,
              Equipment.Equipment,
              EquipmentModel.EquipmentModel,
              EquipmentOperation.EquipmentOperation,
              EquipmentOperationType.EquipmentOperationType,
              Repair.Repair,
              RightsGroup.RightsGroup,
              Task.Task,
              TaskOperation.TaskOperation,
              TaskPriority.TaskPriority,
              TaskState.TaskState]