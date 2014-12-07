%% Bike.org.by document class
%% Author: Andrew O. Shadoura <bugzilla@tut.by>


\NeedsTeXFormat{LaTeX2e}[1995/12/01]
\ProvidesClass{bikedoc}
              [2009/11/19 v0.1
 Bike.org.by document class]

\LoadClass[a4paper,12pt]{extarticle}
\RequirePackage[T2A]{fontenc}
\RequirePackage[utf8]{inputenc}
\RequirePackage[russian]{babel}
\RequirePackage{indentfirst}

\clubpenalty=10000%
\widowpenalty=10000%

\newcommand{\longpage}{\enlargethispage{\baselineskip}}

\frenchspacing%
\setlength{\parindent}{1.25cm}%
\setlength{\parskip}{0pt}% {5pt plus 2pt minus 1pt }
\usepackage[left=2cm,top=2cm,right=1.7cm,bottom=2cm,nohead]{geometry}
%\textheight24cm%
\unitlength1mm%
\renewcommand{\baselinestretch}{1.27}

\usepackage{graphicx}
\usepackage{fix-cm}
\renewcommand\labelitemi{\textendash}

\renewcommand{\appendix}[1]{\bfseries #1 \par}

\newcommand{\attachpicture}[2]{
    \addappendix{Приложение: #2 на 1 л. в 1 экз.\par}
    \addfooter{
        \newpage
        \appendix{Приложение. #2}
        \begin{center}
            \includegraphics[width=\textwidth]{#1}
        \end{center}
    }
}

\newcommand{\addappendix}[1]{\g@addto@macro\bikedoc@appendices{#1}}
\newcommand{\addfooter}[1]{\g@addto@macro\bikedoc@footer{#1}}
\def\to#1{\gdef\@to{#1}}
\def\@to{\@latex@warning@no@line{No \noexpand\to given}~}
\def\address#1{\g@addto@macro\@address{#1\\~\>\space}}
\def\@address{}
\def\refno#1{\gdef\@refno{#1}}
\def\@refno{\@latex@warning@no@line{No \noexpand\refno given}1}
\def\replyto#1#2{\gdef\@replytorefno{#1}\gdef\@replytodate{#2}}
%\def\@replytorefno{}
\def\@replytodate{}

\date{\number\day.\ifcase\month\or01\or02\or03\or04\or05\or06\or07\or08\or09\or10\or11\or12\fi.\number\year}

\pagestyle{empty}

\def\bikedoc@header{%
\makeatletter%
\longpage%
\g@addto@macro\@address{~}
\begin{center}%
\fontsize{10}{10}\selectfont%
\begin{tabular}{cc}
\bfseries \fontsize{12}{12}\selectfont Грамадскае аб'яднанне & \bfseries \fontsize{12}{12}\selectfont Общественное объединение \\
\bfseries \fontsize{20.74}{20}\selectfont <<Мінскае роварнае & \bfseries \fontsize{20.74}{20}\selectfont <<Минское велосипедное \\
\bfseries \fontsize{20.74}{20}\selectfont таварыства>> & \bfseries \fontsize{20.74}{20}\selectfont общество>> \\
вул. Смалячкова, 14А, г. Мінск, 220005 & ул. Смолячкова, 14А, г. Минск, 220005 \\
тэл. +375 29 779 31 85 & тел. +375 29 779 31 85 \\
e-mail: info@bike.org.by & e-mail: info@bike.org.by \\
р/р 3015020977017 & р/c 3015020977017 \\
у ЦБП 113 ААТ <<Пріорбанк>>, код 153001749, & в ЦБУ 113 ОАО <<Приорбанк>>, код 153001749, \\
г. Мінск, вул. Камсамольская, 13 & г. Минск, ул. Комсомольская, 13 \\
УНП 194902167, АКПА 379736485000 & УНП 194902167, ОКПО 379736485000
\end{tabular}
\rule{\textwidth}{0.75mm}\\[-1em]%
%\vspace{0.5mm}
\rule{\textwidth}{0.15mm}%
\end{center}
\begin{tabbing}
\hspace{0.5\textwidth} \= ~ \kill
\@date~№\@refno \> \@to \\
\ifx \@replytorefno \undefined \else {На №\@replytorefno~от~\@replytodate} \fi \> \@address
\end{tabbing}%
\@title
\vskip 1ex
\makeatother%
}

\def\bikedoc@appendices{%
}

\def\bikedoc@footer{%
\makeatletter%
%\noindent \@from~\hfill\underline{\hspace{3cm}}~/~\@fromname~/%
\bikedoc@appendices%
\vskip 0.7ex
Председатель правления\hfill{~~~~~~~~~~~~~}~Е.~А.~Хоружий
\makeatother%
}%
%
\AtBeginDocument{%
\thispagestyle{empty}
\pagestyle{plain}

\makeatletter%
\bikedoc@header

%\@title~\\[1ex]%
\makeatother}
\AtEndDocument{%

\vskip 1.5ex

\makeatletter%
\bikedoc@footer%
\makeatother%
}

\endinput

