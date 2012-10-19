import DepartmentActivitySphere # --.                                    | f
import Department               # <-'            --.                     |
import DetailCategory           # --.              |                     |
import DetailModel              # <-'              |  --.                |
import EmployeeRole             # --.              |    |                | f
import RightsGroup              #   |  --.         |    |                | f
import Employee                 # <-'  <-'  --.    |    |                |
import EmployeeOperationType    # --.         |    |    |                | f
import EmployeeOperation        # <-'       <-'  <-'    |  --.           |
import EquipmentCategory        #      --.              |    |           |
import EquipmentModel           # --.  <-'              |    |           |
import Equipment                # <-'  --.              |    |           |
import EquipmentOperationType   # --.    |              |    |           | f
import EquipmentOperation       # <-'  <-'       --.    |    |           |
import EquipmentOwner           #                  |    |    |           |
import TaskPriority             #           --.    |    |    |           | f
import Task                     # --.  --.  <-'    |    |    |           |
import Repair                   # <-'    |       <-'  <-'    |           |
import TaskState                # --.    |                   |           | f
import TaskOperation            # <-'  <-'                 <-'           |

all_models = [Department.Department,
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
              RightsGroup.RightsGroup,
              Task.Task,
              TaskOperation.TaskOperation,
              TaskPriority.TaskPriority,
              TaskState.TaskState]