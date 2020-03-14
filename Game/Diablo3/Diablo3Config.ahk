class Diablo3Config {
    static PARAGON := 1000 ;巅峰等级
    static KEY_SKILL := ["1", "2", "3", "4"] ;技能按键绑定
    static KEY_CLEAR := "Space" ;技能按键绑定
    static FIRE_DELAY := Array([0, 150, 0, 0, 150, 0], [0, 0, 0, 0, 150, 0], [0, 0, 0, 0, 150, 0]) ;开火模式设置
}

/*

Loop % FIRE_MODE_MAP.Length()
    MsgBox % array[A_Index]

For index, value in APP.FIRE_MODE_MAP[1]
    MsgBox % "Item " index " is '" value "'"

*/
