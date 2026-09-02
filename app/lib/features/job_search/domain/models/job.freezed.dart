// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'job.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Job {

 String get id; String get source; String get title; String? get company; String? get location; String? get description; String? get postedDate; String? get applicationEmail; String? get applicationUrl;
/// Create a copy of Job
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JobCopyWith<Job> get copyWith => _$JobCopyWithImpl<Job>(this as Job, _$identity);

  /// Serializes this Job to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Job&&(identical(other.id, id) || other.id == id)&&(identical(other.source, source) || other.source == source)&&(identical(other.title, title) || other.title == title)&&(identical(other.company, company) || other.company == company)&&(identical(other.location, location) || other.location == location)&&(identical(other.description, description) || other.description == description)&&(identical(other.postedDate, postedDate) || other.postedDate == postedDate)&&(identical(other.applicationEmail, applicationEmail) || other.applicationEmail == applicationEmail)&&(identical(other.applicationUrl, applicationUrl) || other.applicationUrl == applicationUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,source,title,company,location,description,postedDate,applicationEmail,applicationUrl);

@override
String toString() {
  return 'Job(id: $id, source: $source, title: $title, company: $company, location: $location, description: $description, postedDate: $postedDate, applicationEmail: $applicationEmail, applicationUrl: $applicationUrl)';
}


}

/// @nodoc
abstract mixin class $JobCopyWith<$Res>  {
  factory $JobCopyWith(Job value, $Res Function(Job) _then) = _$JobCopyWithImpl;
@useResult
$Res call({
 String id, String source, String title, String? company, String? location, String? description, String? postedDate, String? applicationEmail, String? applicationUrl
});




}
/// @nodoc
class _$JobCopyWithImpl<$Res>
    implements $JobCopyWith<$Res> {
  _$JobCopyWithImpl(this._self, this._then);

  final Job _self;
  final $Res Function(Job) _then;

/// Create a copy of Job
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? source = null,Object? title = null,Object? company = freezed,Object? location = freezed,Object? description = freezed,Object? postedDate = freezed,Object? applicationEmail = freezed,Object? applicationUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,company: freezed == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,postedDate: freezed == postedDate ? _self.postedDate : postedDate // ignore: cast_nullable_to_non_nullable
as String?,applicationEmail: freezed == applicationEmail ? _self.applicationEmail : applicationEmail // ignore: cast_nullable_to_non_nullable
as String?,applicationUrl: freezed == applicationUrl ? _self.applicationUrl : applicationUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Job].
extension JobPatterns on Job {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Job value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Job() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Job value)  $default,){
final _that = this;
switch (_that) {
case _Job():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Job value)?  $default,){
final _that = this;
switch (_that) {
case _Job() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String source,  String title,  String? company,  String? location,  String? description,  String? postedDate,  String? applicationEmail,  String? applicationUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Job() when $default != null:
return $default(_that.id,_that.source,_that.title,_that.company,_that.location,_that.description,_that.postedDate,_that.applicationEmail,_that.applicationUrl);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String source,  String title,  String? company,  String? location,  String? description,  String? postedDate,  String? applicationEmail,  String? applicationUrl)  $default,) {final _that = this;
switch (_that) {
case _Job():
return $default(_that.id,_that.source,_that.title,_that.company,_that.location,_that.description,_that.postedDate,_that.applicationEmail,_that.applicationUrl);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String source,  String title,  String? company,  String? location,  String? description,  String? postedDate,  String? applicationEmail,  String? applicationUrl)?  $default,) {final _that = this;
switch (_that) {
case _Job() when $default != null:
return $default(_that.id,_that.source,_that.title,_that.company,_that.location,_that.description,_that.postedDate,_that.applicationEmail,_that.applicationUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Job implements Job {
  const _Job({required this.id, required this.source, required this.title, this.company, this.location, this.description, this.postedDate, this.applicationEmail, this.applicationUrl});
  factory _Job.fromJson(Map<String, dynamic> json) => _$JobFromJson(json);

@override final  String id;
@override final  String source;
@override final  String title;
@override final  String? company;
@override final  String? location;
@override final  String? description;
@override final  String? postedDate;
@override final  String? applicationEmail;
@override final  String? applicationUrl;

/// Create a copy of Job
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JobCopyWith<_Job> get copyWith => __$JobCopyWithImpl<_Job>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$JobToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Job&&(identical(other.id, id) || other.id == id)&&(identical(other.source, source) || other.source == source)&&(identical(other.title, title) || other.title == title)&&(identical(other.company, company) || other.company == company)&&(identical(other.location, location) || other.location == location)&&(identical(other.description, description) || other.description == description)&&(identical(other.postedDate, postedDate) || other.postedDate == postedDate)&&(identical(other.applicationEmail, applicationEmail) || other.applicationEmail == applicationEmail)&&(identical(other.applicationUrl, applicationUrl) || other.applicationUrl == applicationUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,source,title,company,location,description,postedDate,applicationEmail,applicationUrl);

@override
String toString() {
  return 'Job(id: $id, source: $source, title: $title, company: $company, location: $location, description: $description, postedDate: $postedDate, applicationEmail: $applicationEmail, applicationUrl: $applicationUrl)';
}


}

/// @nodoc
abstract mixin class _$JobCopyWith<$Res> implements $JobCopyWith<$Res> {
  factory _$JobCopyWith(_Job value, $Res Function(_Job) _then) = __$JobCopyWithImpl;
@override @useResult
$Res call({
 String id, String source, String title, String? company, String? location, String? description, String? postedDate, String? applicationEmail, String? applicationUrl
});




}
/// @nodoc
class __$JobCopyWithImpl<$Res>
    implements _$JobCopyWith<$Res> {
  __$JobCopyWithImpl(this._self, this._then);

  final _Job _self;
  final $Res Function(_Job) _then;

/// Create a copy of Job
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? source = null,Object? title = null,Object? company = freezed,Object? location = freezed,Object? description = freezed,Object? postedDate = freezed,Object? applicationEmail = freezed,Object? applicationUrl = freezed,}) {
  return _then(_Job(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,company: freezed == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,postedDate: freezed == postedDate ? _self.postedDate : postedDate // ignore: cast_nullable_to_non_nullable
as String?,applicationEmail: freezed == applicationEmail ? _self.applicationEmail : applicationEmail // ignore: cast_nullable_to_non_nullable
as String?,applicationUrl: freezed == applicationUrl ? _self.applicationUrl : applicationUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$JobSearchResult {

 List<Job> get jobs; int get page; bool get hasMore;
/// Create a copy of JobSearchResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JobSearchResultCopyWith<JobSearchResult> get copyWith => _$JobSearchResultCopyWithImpl<JobSearchResult>(this as JobSearchResult, _$identity);

  /// Serializes this JobSearchResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JobSearchResult&&const DeepCollectionEquality().equals(other.jobs, jobs)&&(identical(other.page, page) || other.page == page)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(jobs),page,hasMore);

@override
String toString() {
  return 'JobSearchResult(jobs: $jobs, page: $page, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class $JobSearchResultCopyWith<$Res>  {
  factory $JobSearchResultCopyWith(JobSearchResult value, $Res Function(JobSearchResult) _then) = _$JobSearchResultCopyWithImpl;
@useResult
$Res call({
 List<Job> jobs, int page, bool hasMore
});




}
/// @nodoc
class _$JobSearchResultCopyWithImpl<$Res>
    implements $JobSearchResultCopyWith<$Res> {
  _$JobSearchResultCopyWithImpl(this._self, this._then);

  final JobSearchResult _self;
  final $Res Function(JobSearchResult) _then;

/// Create a copy of JobSearchResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? jobs = null,Object? page = null,Object? hasMore = null,}) {
  return _then(_self.copyWith(
jobs: null == jobs ? _self.jobs : jobs // ignore: cast_nullable_to_non_nullable
as List<Job>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [JobSearchResult].
extension JobSearchResultPatterns on JobSearchResult {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JobSearchResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JobSearchResult() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JobSearchResult value)  $default,){
final _that = this;
switch (_that) {
case _JobSearchResult():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JobSearchResult value)?  $default,){
final _that = this;
switch (_that) {
case _JobSearchResult() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Job> jobs,  int page,  bool hasMore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JobSearchResult() when $default != null:
return $default(_that.jobs,_that.page,_that.hasMore);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Job> jobs,  int page,  bool hasMore)  $default,) {final _that = this;
switch (_that) {
case _JobSearchResult():
return $default(_that.jobs,_that.page,_that.hasMore);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Job> jobs,  int page,  bool hasMore)?  $default,) {final _that = this;
switch (_that) {
case _JobSearchResult() when $default != null:
return $default(_that.jobs,_that.page,_that.hasMore);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _JobSearchResult implements JobSearchResult {
  const _JobSearchResult({required final  List<Job> jobs, required this.page, required this.hasMore}): _jobs = jobs;
  factory _JobSearchResult.fromJson(Map<String, dynamic> json) => _$JobSearchResultFromJson(json);

 final  List<Job> _jobs;
@override List<Job> get jobs {
  if (_jobs is EqualUnmodifiableListView) return _jobs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_jobs);
}

@override final  int page;
@override final  bool hasMore;

/// Create a copy of JobSearchResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JobSearchResultCopyWith<_JobSearchResult> get copyWith => __$JobSearchResultCopyWithImpl<_JobSearchResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$JobSearchResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _JobSearchResult&&const DeepCollectionEquality().equals(other._jobs, _jobs)&&(identical(other.page, page) || other.page == page)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_jobs),page,hasMore);

@override
String toString() {
  return 'JobSearchResult(jobs: $jobs, page: $page, hasMore: $hasMore)';
}


}

/// @nodoc
abstract mixin class _$JobSearchResultCopyWith<$Res> implements $JobSearchResultCopyWith<$Res> {
  factory _$JobSearchResultCopyWith(_JobSearchResult value, $Res Function(_JobSearchResult) _then) = __$JobSearchResultCopyWithImpl;
@override @useResult
$Res call({
 List<Job> jobs, int page, bool hasMore
});




}
/// @nodoc
class __$JobSearchResultCopyWithImpl<$Res>
    implements _$JobSearchResultCopyWith<$Res> {
  __$JobSearchResultCopyWithImpl(this._self, this._then);

  final _JobSearchResult _self;
  final $Res Function(_JobSearchResult) _then;

/// Create a copy of JobSearchResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? jobs = null,Object? page = null,Object? hasMore = null,}) {
  return _then(_JobSearchResult(
jobs: null == jobs ? _self._jobs : jobs // ignore: cast_nullable_to_non_nullable
as List<Job>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
