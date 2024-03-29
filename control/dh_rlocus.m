%function dh_bode(tf0)
if 1
    % tf0: sysOL
    %clc; clf; clear
    % s vari for TF
    s=tf('s');
    % x vari for symbolic calc.
    % 점근선, 브레이크포인트 수직선, DCgain 표시를 위한 계산용
    syms x;
    

    %% 
    % 1. TF 1개 선택
    % tf_3b tf_3e tf_3f tf_3h
    % tf_4a tf_4c  tf_5a tf_5b tf_5d
    % tf_6b tf_6g tf_7a tf_7d tf_8b tf_8c
    fname='tf_';
    tf0=100*(s/10+1)/s/(s-1)/(s/100+1);
   

    %
    % 1-1. 선택된 TF 특성 파악
    %

    % dh_info(tf0)
    
    %
    % 1-2. TF 약분 
    % 점근선 계산용
    
    % 1) tf to sym
    [Num,Den] = tfdata(tf0); % control TF
    num_p = poly2sym(cell2mat(Num),x);
    den_p = poly2sym(cell2mat(Den),x);
    tf_sym=num_p/den_p; % 약분 후 TF
    % * mag, phase 아래식으로 직접 구할 수 있음. (bode 함수 대용)
    % eval(abs(subs(tf_sym,x,1j)));
    
    % 2) sym to tf
    [symNum,symDen] = numden(tf_sym); % Symbolic TF
    TFnum = sym2poly(symNum);    % Symbolic num to polynomial
    TFden = sym2poly(symDen);    % Symbolic den to polynomial
    tf0 =tf(TFnum,TFden);
    % 약분 후 pole, zero
    p0=pole(tf0);
    z0=zero(tf0);
    
    % bode from
    tf_zpk=zpk(tf0); tf_zpk
    
        
    
    %%
    % 2. 그래프
    % 
    rlocus(tf0)

    % g0) 그래프 핸들 얻기
    if 1
        % Get the handles of the axes
        ax=findobj(gcf,'type','axes');
        ax_0=ax(1);
        % Get the X axis limits (it is the same for both the plot
        ax_xlim=ax_0.XLim;
        % Get the Y axis limits
        ax_ylim=ax_0.YLim;
    end
    
    %% 
    % 3a. 그래프에 추가할 정보 
    % g1) aymptote: center and angle
    % g2) in and out (x axis)
    % g3) y axis
    % g4) 

    % asymptote: center and slope
    np=length(p0); nz=length(z0);
    pzdiff=np-nz;
    asymp_c=(sum(p0)-sum(z0))/pzdiff % center point
    asymp_s=180/pzdiff % slope
    
    % x axis crossover (real)
    % diff K = 0 중 일부
    eq_K=-1/tf_sym;
    xcr=vpasolve(diff(eq_K,x)); xcr=double(xcr);
    xcr_K=subs(eq_K,x,xcr); % symbolic
    xcr_K=double(xcr_K);
    xcr_k=[xcr, xcr_K]

    % y axis crossover (imag)
    % 
    syms K w0 real
    den_p;
    eq_rlocus=den_p+K*num_p;
    eq_y=subs(eq_rlocus,x,w0*j);    
    ycr=solve([real(eq_y), imag(eq_y)], [w0,K]);
    ycr_k=eval([ycr.w0, ycr.K])
    % rlocfind(tf0)

    %% 
    % 3b. 그래프 표시
    % g1) Break point: vline
    % g2) DCgain point for low frequency asymtote
    
    % 1) 점근선 포인트 추가 (수직선)
    lsepc_bk={':','Color',[0.5 0 0.8], 'LineWidth', 1.5};
    % center and slope

    % 점근선 수식: 1차식 (기울기+한 점)
    % 1) 점근선 중심점 추가 (빨강점)
    if 1
        hold on    
        ze0=zeros(length(asymp_c),1);
        plot([asymp_c asymp_c],[ze0 ze0],'pc');
        text(xcr,zeros(length(xcr),1),num2str(xcr_K))
    end

    % 90도 인경우, 그냥 y 수직선
    % 나머지는 직선 방정식
    for i = 1:length(asymp_c)
        if asymp_c(i)==90
            plot([asymp_c asymp_c],ax_ylim,'--');
        else
            x0=asymp_c(i); y0=0;
            x1=ax_xlim(2); y1=tan(asymp_s(i)*pi/180)*(x1-x0)+y0;
            plot([x0 x1],[y0 y1],'--');
        end
    end
    
    % 2) x axis 추가 (빨강점)
    % 
    if 1
        hold on 
        plot([xcr xcr],[0.1 0.1],'^r');
        text(xcr,zeros(length(xcr),1),num2str(xcr_K));
    end

    % 3) y axis 추가 (빨강점)
    % 
    if 1
        hold on    
        plot([0 0],[ycr.w0 ycr.w0],'sb');
        text(zeros(length(ycr.w0),1),ycr.w0,num2str(double(ycr.K)) );
    end

end
    
    % summary
    %print('DC gain=',K0, 'Const K of bode form', K0)
    
    % 버전
    % 1 matlab (PC): zbook에서 잘되나, 북2 5g에서 잘 안됨.
    % 2 Octave (PC): 핸드캐리용 노트북에서 할때 (매트랩 대용)
    % 3 Python (colab): 태블릿으로 할 때
    % 4 Python ( ): 태블릿으로 할 때