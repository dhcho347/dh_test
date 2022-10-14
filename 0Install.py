1.Anaconda3 설치
1.1 필요시 path 설정
  path C:\ProgramData\Anaconda3;
       C:\ProgramData\Anaconda3\Library;
       C:\ProgramData\Anaconda3\Scripts
 or 찾기 : 고급 시스템 설정 보기 > 환경변수 > 시스템변수탭, path에 3줄 추가
  
  
2. vscode 설치

3. gitHub에서 floris 가져오기
 git clone -b main https://github.com/NREL/floris.git
 
4. Conda 가상환경 구성
4-1. floris 폴더에서

conda info --envs

# py39라는 가상환경 생성
conda create --name py39

#가상환경 복사 (py39를 venv로
conda create --name venv --clone py39
 
#가상환경 활성화
conda activate py39

conda install -c conda-forge pyoptsparse
conda install pip (필요한가? pip 최신화, upgrade)

conda install -c conda-forge floris

conda install --file requirments.txt
 #vs에서 실패
 #pycharm 으로 열면, 자동으로 필수 라이브러리 설치해줌
 
 
 
 #확인용
 python -v
 
 conda --version
 
 #패키치, 버전 확인
 conda list
 conda list python
 conda list numpy
 
 # numpy version downgrade
 conda uninstall -y numpy
 conda uninstall -y setuptools
 conda install setuptools
 conda install numpy
 
 
 
 ##기존 설명
 # cmd 명령어
1. python 설치
2. VS code 설치
3. git 설치

윈도우+R -> cmd -> 명령프롬포트 창 실행
cd desktop    // 바탕화면으로 이동
mkdir 폴더명  // 현재 경로에 floris를 설치할 폴더 생성
cd 폴더명      // 폴더 진입
git clone -b main https://github.com/NREL/floris.git  // github의 floris 설치
cd floris        // floris 진입
phyton -m venv venv   // venv라는 가상환경 구성
venv\Script\activate   // 가상환경 구동

python -m pip install --upgrade pip   // pip 최신화
python -m pip install .    // floris 구동에 필요한 pip 설치
code .                    // vs코드 실행

cd examples  // floris 내 examples 코드 존재
python 02_visualizations.py   // python 02 쓰고 탭 누르면 자동으로 입력, 실행 시 02번 예제 실행

cd floris        // floris 진입
python -m venv venv   // venv라는 가상환경 구성
cd venv\Script
activate.bat   // 가상환경 구동
.\venv\Script\activate.bat

python -m pip install --upgrade pip   // pip 최신화
cd..
python -m pip install .    // floris 구동에 필요한 pip 설치
code .                    // vs코드 실행

cd examples  // floris 내 examples 코드 존재
python 02_visualizations.py   // python 02 쓰고 탭 누르면 자동으로 입력, 실행 시 02번 예제 실행

conda info --envs
conda activate myenv
 
