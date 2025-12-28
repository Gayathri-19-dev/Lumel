USE msdb;
GO
-- 1. Create the Job
EXEC dbo.sp_add_job 
    @job_name = N'Daily_CSV_Import_Job';

-- 2. Add the Step (Executing your procedure)
EXEC sp_add_jobstep 
    @job_name = N'Daily_CSV_Import_Job', 
    @step_name = N'Run_SP_ImportSalesData', 
    @subsystem = N'TSQL', 
    @command = N'EXEC Lumel.dbo.SP_ImportSalesData;', 
    @retry_attempts = 1, 
    @retry_interval = 5;

-- 3. Create the Schedule (10:00 PM Daily)
EXEC dbo.sp_add_schedule 
    @schedule_name = N'Daily_10PM_Schedule', 
    @freq_type = 4,          -- Daily
    @freq_interval = 1,      -- Every 1 day
    @active_start_time = 220000; -- 22:00:00 (10 PM)

-- 4. Attach the Schedule to the Job
EXEC sp_attach_schedule 
   @job_name = N'Daily_CSV_Import_Job', 
   @schedule_name = N'Daily_10PM_Schedule';

-- 5. Target the local server
EXEC dbo.sp_add_jobserver 
    @job_name = N'Daily_CSV_Import_Job';
GO