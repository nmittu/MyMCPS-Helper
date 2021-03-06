class Class{
  String courseName;
  String overallgrade;
  String period;
  String sectionid;
  String termid;
  String percent;
  String teacher;
  String room;

  Class({
    this.courseName,
    this.overallgrade,
    this.period,
    this.sectionid,
    this.termid,
    this.percent,
    this.teacher,
    this.room
  });

  factory Class.fromJson(Map<dynamic, dynamic> parsedJson){
    return Class(
        courseName: parsedJson['courseName'],
        overallgrade : parsedJson['overallgrade'],
        period : parsedJson ['period'],
        sectionid : parsedJson ['sectionid'],
        termid : parsedJson ['termid'],
        percent :parsedJson ['percent'],
        teacher :parsedJson ['teacher'],
        room :parsedJson ['room']
    );
  }
}