clear all; close all; clc;

% Script developed from this problem (in french) :
% https://physique.ensta-paris.fr/PAT/DM/DM4_rotateur.pdf

% ---------- PARAMETERS ------------

% Number of initial conditions
CI=200;

% Different K to plot
K=[0 0.4 1 1.4 2.2 8];

% Total number of iterations
N=1000;

% Size of the points on the figure
cz=3;

% one / two
type = "two";

% ---------- BEGINNING OF THE SCRIPT ------------

rng("shuffle");
rho0 = (2 * pi - eps) * rand(1, CI);
theta0 = (2 * pi - eps) * rand(1, CI);

s=size(K);
nK = s(2);

figure('Name', "Tracé des sections de Poincarré pour " + CI + " conditions initiales et " + N + " itérations")
for i = 1:nK
    subplot(nK/3, 3, i);
    
    theta=ones(N, 1) * theta0; % theta
    rho=ones(N, 1) * rho0; % y

    for n=2:N
        if type == "one"
            theta(n,:) = mod(theta(n-1,:) + rho(n-1,:), 2 * pi);
            rho(n,:) = mod(rho(n-1,:) + K(i) * sin(theta(n,:)), 2 * pi);
        elseif type == "two"
            step=sin(rho(n-1,:) + theta(n-1,:));
            theta(n,:) = mod(theta(n-1,:) + 2*rho(n-1,:) + K(i)*step, 2 * pi);
            rho(n,:) = mod(rho(n-1,:) + K(i) * (step - sin(theta(n,:))), 2 * pi);
        end
    end

    scatter(theta, rho, cz, 'filled')
    xlabel('θ')
    ylabel('ρ')
    set(gca,'XTick',0:pi/2:2*pi)
    xlim([0 2*pi])
    ylim([0 2*pi])
    set(gca,'XTickLabel',{0,'π/2','π', '3π/2', '2π'})
    set(gca,'YTick',0:pi/2:2*pi)
    set(gca,'YTickLabel',{0,'π/2','π', '3π/2', '2π'})
    title("K=" + K(i))
end

grid on

