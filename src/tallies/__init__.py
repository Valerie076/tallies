from re import Match


from enum import Enum
from datetime import datetime
import re
from typing import override

class Priority(Enum):
    A = 1
    B = 2
    C = 3
    D = 4
    E = 5
    F = 6
    G = 7
    H = 8
    I = 9
    J = 10
    K = 11
    L = 12
    M = 13
    N = 14
    O = 15
    P = 16
    Q = 17
    R = 18
    S = 19
    T = 20
    U = 21
    V = 22
    W = 23
    X = 24
    Y = 25
    Z = 26

class Todo:
    tasks: list[Task] = []
    
    def __init__(self, file: str) -> None:
        self.file: str = file

        with open(file, "r") as f:
            for line in f.readlines():
                parse: Task | None = self._parse_line(line)
                if parse:
                    self.add_task(parse)
    
    def _save(self) -> None:
        with open(self.file, "w") as f:
            for task in self.tasks:
                _ = f.write(str(task) + "\n")

    def _parse_line(self, line: str) -> Task | None:
        task: Task = Task("")

        parts: list[str] = line.split()
        
        # Is the task completed
        if parts[0] == "x":
            task.completed = True
            _ = parts.pop(0)
        
        # Is the task prioritized
        if "(" in parts[0]:
            if parts[0][1].isupper() and parts[0][1].isalpha():
                task.priority = Priority[parts[0][1]]
            _ = parts.pop(0)

        # If it has 1 date, assume creation date, if it has 2 dates, it is both 
        date1_match: Match[str] | None = re.match(r"\d{4}-\d{2}-\d{2}", parts[0])
        date2_match: Match[str] | None = re.match(r"\d{4}-\d{2}-\d{2}", parts[1])

        # If two dates
        if date1_match and date2_match:
            task.completion_date = parts[0]
            task.creation_date = parts[1]
            _ = parts.pop(0)
            _ = parts.pop(0)
        
        # If one date
        elif date1_match and date2_match is None:
            task.creation_date = parts[0]
            _ = parts.pop(0)
        
        # What projects are specified
        projects: list[str] = re.findall(r"\+(\S+)", line)
        if projects:
            for proj in projects:
                task.projects.append(proj)
                _ = parts.remove("+" + proj)

        # What contexts are specified
        contexts: list[str] = re.findall(r"@(\S+)", line)
        if contexts:
            for ctx in contexts:
                task.contexts.append(ctx)
                _ = parts.remove("@" + ctx)
        
        # What special tags are specified
        tags: dict[str, str] = {}
        tags_list: list[str] = re.findall(r"(\S+):(\S+)", line)
        for tag in tags_list:
            tags[tag[0]] = tag[1]
            _ = parts.remove(tag[0] + ":" + tag[1])
        task.tags = tags

        # Description
        task.desc = " ".join(parts)

        return task

    def add_task(self, task: Task) -> None:
        self.tasks.append(task)
        self._save()

    def create_task(
        self,
        desc: str = "Task",
        creation_date: str | None = None,
        completion_date: str | None = None,
        priority: Priority | None = None,
        projects: list[str] | None = None,
        contexts: list[str] | None = None,
        tags: dict[str, str] | None = None,
        completed: bool = False
    ) -> Task:
        task = Task(
            desc,
            creation_date,
            completion_date,
            priority,
            projects,
            contexts,
            tags,
            completed
        )
        self.tasks.append(task)
        self._save()
        return task
    
    def complete_task_by_index(self, index: int) -> None:
        self.tasks[index].complete_task()
        self._save()
    
    def complete_task(self, task: Task) -> None:
        task.complete_task()
        self._save()
        
    def search_by_desc(self, query: str, case_sensitive: bool = False) -> list[Task] | None:
        result: list[Task] = [task for task in self.tasks if query in task.desc] if case_sensitive \
                        else [task for task in self.tasks if query.upper() in task.desc.upper()]
        return sorted(result, key=lambda t: t.desc)

class Task:
    def __init__(
        self,
        desc: str,
        creation_date: str | None = None,
        completion_date: str | None = None,
        priority: Priority | None = None,
        projects: list[str] | None = None,
        contexts: list[str] | None = None,
        tags: dict[str, str] | None = None,
        completed: bool = False
    ) -> None:
        self.desc: str = desc
        self.creation_date: str | None = creation_date
        self.completion_date: str | None = completion_date
        self.priority: Priority | None = priority
        self.projects: list[str] = projects if projects is not None else []
        self.contexts: list[str] = contexts if contexts is not None else []
        self.tags: dict[str, str] = tags if tags is not None else {}
        self.completed: bool = completed
        
        if not creation_date:
            self.creation_date = get_current_date()

    def complete_task(self) -> None:
        self.completed = True
        self.completion_date = get_current_date()

    @override
    def __str__(self) -> str:
        out: str = ""

        out += "x " if self.completed else ""

        out += f"({self.priority.name}) " if self.priority else ""

        out += get_current_date() + " " if self.completed else ""

        out += self.creation_date + " " if self.creation_date else ""

        out += self.desc.strip() + " "

        out += " ".join(["+" + proj for proj in self.projects]) + " " if len(self.projects) > 0 else ""
        
        out += " ".join(["@" + ctx for ctx in self.contexts]) + " " if len(self.contexts) > 0 else ""

        for key, value in self.tags.items():
            out += f"{key}:{value} "

        return out.strip()

def get_current_date() -> str:
    return datetime.today().strftime('%Y-%m-%d')

if __name__ == "__main__":
    todo: Todo = Todo("todo.txt")

    t = todo.create_task("new task")
    todo.complete_task(t)
    
    # todo.create_task("Do something cool", projects=["project"], contexts=["context"])
    # todo.create_task("Do something cool but i did it", priority=Priority.A, completed=False, projects=["project"], contexts=["context"])
    # todo.create_task("Special args task", completed=False, tags={"due": "2026-09-17", "awesome": "yes"})

    # s: list[Task] | None = todo.search_by_desc("cool")
    # if s:
    #     for t in s:
    #         # print(t)
    #         print()

    # s2 = todo.search_by_desc("did it")
    # if s2 and len(s2) > 0:
    #     todo.complete_task(s2[0])

    # todo.complete_task_by_index(2)

    # for task in todo.tasks:
    #     print(str(task))