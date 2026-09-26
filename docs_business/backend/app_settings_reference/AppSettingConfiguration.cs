using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace XStore.AppSettings;

/// <summary>Register with modelBuilder.ApplyConfiguration(new AppSettingConfiguration()) (or ApplyConfigurationsFromAssembly).</summary>
public class AppSettingConfiguration : IEntityTypeConfiguration<AppSetting>
{
    public void Configure(EntityTypeBuilder<AppSetting> b)
    {
        b.ToTable("AppSettings");
        b.HasKey(x => x.Id);
        b.Property(x => x.Key).IsRequired().HasMaxLength(100);
        b.HasIndex(x => x.Key).IsUnique();
        b.Property(x => x.Value).IsRequired(); // nvarchar(max): Json values can be large
        b.Property(x => x.DataType).HasConversion<int>();
        b.Property(x => x.Description).HasMaxLength(500);
        b.Property(x => x.CreatedBy).IsRequired().HasMaxLength(150);
        b.Property(x => x.UpdatedBy).HasMaxLength(150);
    }
}
