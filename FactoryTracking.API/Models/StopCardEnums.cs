namespace FactoryTracking.API.Models
{
    public enum StopCardStatus
    {
        Open = 0,
        InProgress = 1,
        Resolved = 2,
        Closed = 3
    }

    public enum StopCardPriority
    {
        Low = 0,
        Medium = 1,
        High = 2,
        Critical = 3
    }
}