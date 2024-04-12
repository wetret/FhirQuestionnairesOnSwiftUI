import Foundation

public protocol PRODateTimeStep: PROStepWithResult where ResultType == PRODateResult
{
    var result: ResultType { get }
}
