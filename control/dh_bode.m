function dh_bode(tf0)
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
    %tf0=tf_8c;
   
    %
    % 1-1. 선택된 TF 특성 파악
    %
    
    % 1) 보드폼 (확인용)
    % bode from
    tfzpk=zpk(tf0);
    tfzpk.DisplayFormat='frequency';
    tfzpk
    
    % 2) Poles and zeros
    % 약분 전...
    p0x=pole(tf0);
    z0x=zero(tf0);
    
    % 3) damp, wn both (OL, CL)
    damp(tf0)
    
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
    % bode plot
    margin(tf0)
    %bode(tf0, tf_1,'--y', tf_2,'--y',tf_3,'--y')
    %bodeplot(tf0)
    
    %% 
    % 3a. 그래프에 추가할 정보 
    % g1) Break point: vline
    % g2) DCgain point for low frequency asymptote
    % g3) asymptote line
    % g4) Margin
    
    % g0) 그래프 핸들 얻기
    if 1
        % Get the handles of the axes
        ax=findobj(gcf,'type','axes');
        phase_ax=ax(1);
        mag_ax=ax(2);
        % Get the X axis limits (it is the same for both the plot
        ax_xlim=phase_ax.XLim;
        % Get the Y axis limits
        phase_ylim=phase_ax.YLim;
        mag_ylim=mag_ax.YLim;
    end
    
    %
    % g1) 분기점 (breakpoints)
    % 
    % => g3)에서 한 번에
    
    %
    % g2) DC gain 계산
    % 
    % * numden 문제: simplify (분모의 최고차항을 1로 만 든 후의 분자값을 줌.)
    % 최소차항만 보면 됨.
    
    num=coeffs(num_p); % poly to coeffs array
    den=coeffs(den_p); % poly to coeffs array
    % 분자, 분모 최소차수 계수
    num0=double(num(1)); % 최소차항 계수
    den0=double(den(1)); % 최소차항 계수
    
    % DC gain
    K0=num0/den0; % bode form의 분자 상수 (K)
    K0=abs(K0); % RHS -> negative
    DCg=20*log10(K0); % DC gain (20log10(K))
    
    
    %
    % g3) 점근선: 기울기, 분기점
    % 
    [num_b,den_b]=numden(tf_sym); % tf_sym: symbolic TF
    
    % 점근선은 극점, 영점(1차항) 혹은 고유진동수(2차항)에서 구분됨
    % 분기점: 방정식의 근 이용
    % % 1차항은 pole or gain => 방정식의 근 이용
    % % 2차항은 pole은 복소수(z=sig+jwd) => wn=abs(z), 근의 크기 이용
    % 기울기: 근의 개수, 각도: 근의개수 * 90도
    
    for i_nd = 1:2
        if i_nd ==1
            coeff=den_b;
        else
            coeff=num_b;
        end
    
        l_root=-round(vpasolve(coeff,x),3)
        if ~isempty(l_root) % 근이 없으면 실행 x
            clear i_v l_root_real l_root_complex pz_c pz_r cnt
            v=l_root; 
            for i = 1:length(v)
                i_v(i)=isreal(v(i));
            end
            l_root_real=l_root(i_v);
            l_root_complex= l_root(~i_v);
            
            id_r=~isempty(l_root_real);
            id_c=~isempty(l_root_complex);
        
            % 종류별 카운트: real
            if id_r
                v=double(l_root_real);
                numbers=sort(unique(v));
                for i = 1:length(numbers);
                    ind = v==numbers(i);
                    cnt(i)=sum(ind);
                end
                pz_r=[numbers';cnt];
            end
        
            % 종류별 카운트: complex type2
            % 근은 다르지만, wn 이 같으면? 점근선은 동일. 구분 불필요
            if id_c
                v=double(l_root_complex); % 복소근
                v=double(abs(l_root_complex)); % wn, 
                % for RHS: 부호추가 + real 명령어 때문에 순허수와 분리
                % 순허수 구분. (real => 0)
                a1=find(real(l_root_complex)==0);
                v(a1)=double(abs(l_root_complex(a1)));
                % 복소수
                a1=find(real(l_root_complex)~=0);
                v(a1)=double(round(sign(real(l_root_complex(a1))).*double(abs(l_root_complex(a1))),3)); % 순허수.
                numbers=sort(unique(v));
                cnt=0;
                for i = 1:length(numbers);
                    ind = (v==numbers(i));
                    cnt(i)=sum(ind);
                end
                pz_c=[numbers';cnt];
            end
    
            % 실수, 복소수 합
            if id_r 
                if id_c
                    pz0=[pz_c pz_r]; % 두 가지 모두 있는 경우
                else
                    pz0=[pz_r]; % 실수만 있는 경우
                end
            else
                if id_c   
                    pz0=[pz_c]; % 허수만 있는 경우
                end
            end
            
            % 분모,분자 합
            if i_nd==1 % 분모
                pz0(2,:)= -pz0(2,:); % 분모는 기울기 -
                pz=pz0 ;
            else % 분자
                pz=[pz pz0];
            end
        end
    end
    
    % 기울기 분리. for RHS
    pz(3,:)=pz(2,:);
    
    %
    % 추가. type1 보정
    % s 항 보정. 0이 있으면
    pz0=pz;
    a0=find(pz0(1,:)==0);
    if a0>0
        pz0(2,a0)==1;
    else
        pz0=[pz0 [0;0;0]];
    end
    
    %
    % 추가. RHS 보정  for RHS
    % 
    % real 
    % pz에 음수 추가됨. 
    a0=find(pz0(1,:)<0);
    phase0=180*sum(pz0(3,a0)) ;
    if a0>0
        pz0(1,a0)=-pz0(1,a0); % - break pts
        pz0(3,a0)=-pz0(3,a0); % - slope for phase
    end
    
    % complex 
    % DCg가 허수 
    % pz에 음수 추가됨. 
    
    
    
    % sort
    % pz 1행: 분기점 정보
    % pz 2행: 분기점의 기울기 정보(분자:+, 분모:-)
    % 1행 기준으로 오름차순 정렬
    [y,in]=sort(pz0(1,:));
    pz=pz0(:,in);
    
    % 4-5행: 기울기 누적
    pz(4,:)=cumsum(pz(2,:)); % slope for mag
    pz(5,:)=cumsum(pz(3,:)); % slope for phase
    
    % 4행: log10(w) 소수점이 늘어남.
    % pz(4,:)=log10(pz(1,:))
    
    %
    % g4) Margin
    % 
    %[Gm, Pm, Wcg, Wcp]=margin(tf);
    
    
    %
    % 실제 지나는 점
    %
    % 6: break point [log10(wn)]
    pz(6,:)=log10(pz(1,:));
    % 7: mag [DB]
    pz(7,2:end)=20*log10(abs(eval((subs(tf_sym,x,pz(1,2:end).*j)))));
    % 7: phase [Deg]
    pz(8,2:end)=angle(eval((subs(tf_sym,x,pz(1,2:end).*j))))*180/pi;
    
    %% 
    % 3b. 그래프 표시
    % g1) Break point: vline
    % g2) DCgain point for low frequency asymtote
    
    % 1) 브레이크 포인트 추가 (수직선)
    lsepc_bk={':','Color',[0.5 0 0.8], 'LineWidth', 1.5};
    % add breakpoints on bode plot
    if 1 % 옥타브에서는 안됨. 
        % Get the handles of the axes
        ax=findobj(gcf,'type','axes');
        phase_ax=ax(1);
        mag_ax=ax(2);
        % Get the X axis limits (it is the same for both the plot
        ax_xlim=phase_ax.XLim;
        % Get the Y axis limits
        phase_ylim=phase_ax.YLim;
        mag_ylim=mag_ax.YLim;
        
        % 위상 그래프 수정
        hold(phase_ax,'on');
        % Add a vertical line in the Phase plot
        for i = pz(1,:)
          plot(phase_ax,[i i],phase_ylim,lsepc_bk{:});
        end
        % Add an horizontal line in the Phase plot
        plot(phase_ax,ax_xlim,[-180 -180],'--');
        plot(phase_ax,ax_xlim,[180 180],'--');
        
        % 크기 그래프 수정
        hold(mag_ax,'on');
        % Add a vertical line in the Magnitide plot
        for i = pz(1,:)
          plot(mag_ax,[i i],mag_ylim,lsepc_bk{:});
        end
        % Add an Horizontal line in the Magnitide plot
        plot(mag_ax,ax_xlim,[0 0],'--');
    end
    
    % 2) DC gain 추가 (빨강점)
    % 
    if 1
        hold(mag_ax,'on')
        plot(mag_ax,[1 1],[DCg DCg],'or'); % w=1 일때, 
        plot(mag_ax,[K0 K0],[0 0],'*k'); % w=K0
        
        plot(mag_ax,ax_xlim,[DCg DCg],':r');
        plot(mag_ax,[1 1],mag_ylim,':r');
    end
    
    %
    % 3) 점근선 추가 (보라선)
    %
    %
    
    if 1
        % 3a) 점근선1: 크기 (mag)
        % 
         [n_row,n_col]=size(pz);
        for i = 1:n_col
            % slope
            slope=sum(pz(2,1:i));
            % const
            if i==1
                x0=1;
                y0=DCg;
            else
                x0=x2;
                y0=y2; 
            end
            if i==n_col
                y0=y2;
            end
            % 점근선 수식: 1차식 (기울기+한 점)
            y=20*slope*(log10(x)-log10(x0))+y0;
        
            % 점근선 양 끝점
            if i==n_col
                x1=pz(1,i); 
                x2=ax_xlim(2); 
            else
                x1=pz(1,i); 
                x2=pz(1,1+i); 
                if i==1 
                    x1=ax_xlim(1);
                end 
            end
            y1=eval(subs(y,x,x1));
            y2=eval(subs(y,x,x2));
            
            % 3) 점근선 추가 (cyan)
            % 크기 그래프 수정
            hold(mag_ax,'on');
            % Add an Horizontal line in the Magnitide plot
            plot(mag_ax,[x1 x2],[y1 y2],'--om');
            %
            asymptote(2*i-1,:)=[x1 y1];
            asymptote(2*i,:)=[x2 y2];
        end
    end
    
    
    % 3b) 점근선2: 위상 (phase)
    % 
    if 1
    
        for i = 1:n_col
            % slope
            slope=sum(pz(3,1:i));
            % 점근선 수식. 수평선 (기울기+한 점)
            y=90*slope;
        
            % 점근선 양 끝점
            if i==n_col
                x1=pz(1,i);
                x2=ax_xlim(2);
            else
                x1=pz(1,i);
                x2=pz(1,1+i); 
                if i==1
                    x1=ax_xlim(1);
                end 
            end
            y1=eval(subs(y,x,x1))+phase0;
            y2=eval(subs(y,x,x2))+phase0;
            
            % 3) 점근선 추가 (cyan)
            % 크기 그래프 수정
            hold(phase_ax,'on');
            % Add an Horizontal line in the Magnitide plot
            plot(phase_ax,[x1 x2],[y1 y2],'--om');
        end
    end
    
    
    %
    % 4) 기타 수정
    %
    
    if 1
            
        % 제목
        % 1) TF 넣기
        % title({'$y=x^2$','$y=x^2$'},'interpreter','latex')
        tftitle = latex(subs(tf_sym,x,'s'));
        title(sprintf('Bode plot of: $$ %s $$', tftitle), 'Interpreter','latex')
        
        % 2) Bode form 넣기
        % tf to sym. 실패. 변환시 보드폼이 유지 안되고, 일반 TF폼으로 변경됨.
        tf_zpk;
        [Num,Den] = tfdata(tf_zpk); % control TF
        num_p = poly2sym(cell2mat(Num),x);
        den_p = poly2sym(cell2mat(Den),x);
        tf_zpk_sym=num_p/den_p; % 약분 후 TF
        
        
        % 그리드
        %
        %mag_ax.YGrid='off';
        mag_ax.XGrid='on';
        phase_ax.XGrid='on';
    end
    
    
    % 그래프 저장
    % 
    %exportgraphics(f,'barchart.png','Resolution',300)
    if 1
        fig=findobj(gcf,'type','figure');
        filename=strcat('ex_',fname,'.png');
        saveas(gcf,filename);
        
        f=gcf;
        filename2=strcat('ex_',fname,'_400','.png');
        exportgraphics(f,filename2,'Resolution',400);
        
        % summary and print to file
        % 파일로 결과창 저장
        filename4=strcat('ex_',fname,'diary','.txt');
        diary(filename4);
    
        tfzpk
        DCg
        pz
        asymptote
    
        diary off
    
        % 파일로 변수 저장 
        %print('DC gain=z',K0, 'Const K of bode form', K0)
        a0=log10(pz(1,:));
        filename3=strcat('ex_',fname,'_mat','.mat');
        save(filename3, 'tfzpk', 'DCg', 'pz', '', 'asymptote');
    end


end
    
    % summary
    %print('DC gain=',K0, 'Const K of bode form', K0)
    
    % 버전
    % 1 matlab (PC): zbook에서 잘되나, 북2 5g에서 잘 안됨.
    % 2 Octave (PC): 핸드캐리용 노트북에서 할때 (매트랩 대용)
    % 3 Python (colab): 태블릿으로 할 때
    % 4 Python ( ): 태블릿으로 할 때