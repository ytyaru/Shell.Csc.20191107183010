# C#コードをコンパイル＆実行する
# 
# コンパイルする。カレントディレクトリ配下の.csファイルをすべて対象にする。実行ファイル名は指定しない限りProgram.exe固定。
CallCsc() { csc -nologo -recurse:*.cs -out:"$(GetOut $@)" $@; }
# 実行ファイル名不定問題
# ======================================
#   cscにおいてコンパイルすると実行ファイルが自動生成される。だが実行権限がないためchmodで付与せねばならない。このとき、実行ファイル名が必要である。
#   実行ファイル名は不定である。デフォルトでは、ソースコードのうちエントリポイント`static void Main`が存在するクラス名を実行ファイル名とする。もし-out引数があれば、その名前を実行ファイル名とする。つまり、これらを動的に取得することで実行ファイル名が判明する。
#   さすがにコード解析するのは大変である。そこで、-out引数により固定名を与えてしまうのが簡単だ。たとえばProgram.exeがデフォルトに近いだろう。エントリポイントがあるクラス名が何であれ固定名を与えることで、コード解析せず実行ファイル名を確定できる。
# cscコマンド引数に-outがあればその値を返す。無ければ空値。
# 
# -outが使えない問題
# ======================================
# 　上記のせいで-out引数が使えない。このcsbuildコマンドは「csc -nologo -recurse:*.cs $@;」のように、特定の引数以外は任意引数を指定できるようにしたかった。だが、実行ファイル名を特定するために固定せねばらなず、任意名が指定できない。
# 　もし任意名を指定したとしても無効になるようにせねばならない。実行ファイル名が特定できなくなってしまうから。引数解析することも考えたが、引数解析が難解すぎて現実的ではない。単なるスペース区切りならよかったが、クォートがあるため複雑。よって-outの受け入れは諦める。
# 
# 対策
# ======================================
# 　先に実行ファイル名に固定名を与えてしまう。
#
# 迷惑
# ======================================
# 　"-out P"でなく"-out:P"という書式。いやスペース区切りにしろよ。そのせいで独自の解析処理を書かねばならんだろうが。
#
GetOut() {
	while [ "$1" != "" ]; do
		[ "${1:0:5}" = '-out:' ] && { echo -n "${1:5}"; return; }
		shift
	done
	echo -n "Program.exe"
}
FindExe() { find . -name *.exe | xargs -I@ basename @; }
CallChmod() { chmod ${2:-755} "$1"; }
RunExe() { "./$1"; }
BuildAndRun() {
	local exe_name="$(GetOut $@)"
	CallCsc $@
	CallChmod "$exe_name"
	RunExe "$exe_name"
}
