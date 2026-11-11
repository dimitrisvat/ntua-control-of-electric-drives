function format_and_export(fig, filename)

    fig.Position = [100, 100, 700, 600];
    
    ax = gca;
    ax.FontSize = 12;         
    ax.FontName = 'Helvetica';   
    ax.Box = 'on';             
    ax.LineWidth = 1;  
    
    exportgraphics(fig, fullfile(pwd,'Figures', filename), 'Resolution', 300);

end