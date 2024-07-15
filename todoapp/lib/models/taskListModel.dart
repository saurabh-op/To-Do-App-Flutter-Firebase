class Task {
  final String taskId;
  final String taskDetail;

  const Task({required this.taskId, required this.taskDetail});

  factory Task.fromJson(String taskDetail, String taskId) => Task(
        taskId: taskId,
        taskDetail: taskDetail,
      );
}
