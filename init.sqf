private _radius = 2;
private _misplacedObjects = [];
private _blacklistedObjects = ["flush_light_yellow_f.p3d", "obstacle_saddle_f.p3d"];

private _world = worldName;
private _size = worldSize;
_roads = [_size / 2, _size / 2] nearRoads _size;


private _getObjectHeight = {
	params ["_object"];
	private _bbr = boundingBoxReal _object;
	private _p1 = _bbr select 0;
	private _p2 = _bbr select 1;
	private _maxHeight = abs ((_p2 select 2) - (_p1 select 2));
	_maxHeight;
};

{
	private _road = _x;
	private _position = position _road;
	private _objects = (nearestObjects [_position, [], _radius]) - _roads;

	{
		private _object = _x;
		private _objectInfo = getModelInfo _object;
		private _objectFile = _objectInfo select 0;
		private _isBlacklistedObject = _objectFile in _blacklistedObjects;

		if (!_isBlacklistedObject) then {
			_misplacedObjects pushBackUnique _x;
		};
	} forEach _objects;
} forEach _roads;

_cam = "camera" camCreate (position player);
_cam cameraEffect ["INTERNAL", "BACK"];
showCinemaBorder false;

{
	private _object = _x;
	private _objectInfo = getModelInfo _object;
	private _objectFile = _objectInfo select 0;
	private _objectHeight = [_object] call _getObjectHeight;
	private _position = position _object;

	private _marker = createMarker [str _object, _position];
	_marker setMarkerShape "ICON";
	_marker setMarkerType "hd_dot";

	_cam camSetTarget _object;
	_cam camSetRelPos [0, 0, _objectHeight + 20];
	_cam camCommit 0;

	private _text = format ["Object: %1\nPosition: %2", _objectFile, _position];
	titleText [_text, "PLAIN"];

	sleep 1;

	private _filename = format ["%1\%2_%3.png", _world, _position select 0, _position select 1];
	screenshot _filename;

	sleep 1;
} forEach _misplacedObjects;

_cam cameraEffect ["terminate","back"];
camDestroy _cam;
